const express = require('express')
const crypto = require('crypto')
const fs = require('fs-extra')
const path = require('path')
const rateLimit = require('express-rate-limit')
const pako = require('pako')
require('dotenv').config()

const app = express()
const PORT = process.env.PORT || 3000
const KEY = Buffer.from(process.env.SECRET_KEY || crypto.randomBytes(32).toString('hex'), 'hex')

app.use(express.json())

const DIR = path.join(__dirname, 'scripts')
fs.ensureDirSync(DIR)

const TOKENS = new Map()
const IV = 16

// ===== AES =====
const enc = (t)=>{
  const iv = crypto.randomBytes(IV)
  const c = crypto.createCipheriv('aes-256-cbc', KEY, iv)
  let e = c.update(t,'utf8','hex')
  e += c.final('hex')
  return iv.toString('hex')+':'+e
}

const dec = (d)=>{
  const [ivh,data]=d.split(':')
  const iv = Buffer.from(ivh,'hex')
  const dc = crypto.createDecipheriv('aes-256-cbc', KEY, iv)
  let r = dc.update(data,'hex','utf8')
  r += dc.final('utf8')
  return r
}

// ===== EMOJI ENCODE =====
const EMOJI = ['🤡','🤢','🤮','🤬','🤫','😈','👻','💀','👽','👾']

const toEmoji = (t)=>t.split('').map(c=>{
  let code=c.charCodeAt(0)
  return EMOJI[code%EMOJI.length]+code.toString(16)
}).join(' ')

const fromEmoji = (t)=>t.split(' ').map(x=>{
  let hex=x.slice(2)
  return String.fromCharCode(parseInt(hex,16))
}).join('')

// ===== PACK =====
const pack = (s)=>{
  let c = Buffer.from(pako.deflate(s)).toString('base64')
  let e = enc(c)
  return toEmoji(e)
}

const unpack = (e)=>{
  let raw = fromEmoji(e)
  let d = dec(raw)
  return pako.inflate(Buffer.from(d,'base64'),{to:'string'})
}

// ===== HASH =====
const hash = (t)=>crypto.createHmac('sha256',KEY).update(t).digest('hex')

// ===== FILTER =====
const badUA = (ua='')=>{
  ua=ua.toLowerCase()
  return ['curl','wget','python','postman','insomnia','httpclient'].some(x=>ua.includes(x))
}

const limiter = rateLimit({windowMs:10000,max:20})

// ===== UPLOAD =====
app.post('/upload',limiter,(req,res)=>{
  let c=req.body.content
  if(!c) return res.status(400).json({error:'no content'})

  const id=crypto.randomBytes(8).toString('hex')
  fs.writeFileSync(path.join(DIR,id+'.enc'),pack(c))

  res.json({
    id,
    loader:`loadstring(game:HttpGet("${req.protocol}://${req.get('host')}/token/${id}"))()`
  })
})

// ===== TOKEN =====
app.get('/token/:id',(req,res)=>{
  if(badUA(req.headers['user-agent'])) return res.status(403).send('denied')

  const id=req.params.id
  const t=crypto.randomBytes(12).toString('hex')
  const ts=Date.now()

  TOKENS.set(t,{id,time:ts})

  const sig=hash(t+ts)

  res.send(`
return (function()
  local t="${t}"
  local ts="${ts}"
  local sig="${sig}"
  local url="${req.protocol}://${req.get('host')}/load/${id}?t="..t.."&ts="..ts.."&sig="..sig
  return game:HttpGet(url)
end)()
`)
})

// ===== LOAD (CHỈ TRẢ EMOJI) =====
app.get('/load/:id',limiter,(req,res)=>{
  const {t,ts,sig}=req.query
  const data=TOKENS.get(t)

  if(!data) return res.status(403).send('bad token')

  if(Date.now()-data.time>10000){
    TOKENS.delete(t)
    return res.status(403).send('expired')
  }

  if(sig!==hash(t+ts)) return res.status(403).send('invalid')

  TOKENS.delete(t)

  const file=path.join(DIR,req.params.id+'.enc')
  if(!fs.existsSync(file)) return res.status(404).send('not found')

  const payload=fs.readFileSync(file,'utf8')

  res.send(`
-- emoji protected
local raw = "${payload}"

local function req(u)
  return game:HttpGet(u)
end

local decoded = req("${req.protocol}://${req.get('host')}/decode?data="..raw)

return loadstring(decoded)()
`)
})

// ===== DECODE API =====
app.get('/decode',(req,res)=>{
  try{
    const data=req.query.data
    if(!data) return res.status(400).send('no data')

    const result=unpack(data)
    res.send(result)
  }catch{
    res.status(403).send('fail')
  }
})

app.use(express.static('public'))

app.listen(PORT,()=>console.log("running "+PORT))
