import express from "express"
import fs from "fs"
import path from "path"

const app = express()
app.use(express.json())

const db = path.join(process.cwd(),"db")
if(!fs.existsSync(db)) fs.mkdirSync(db)

app.get("/",(req,res)=>{
  res.sendFile(path.join(process.cwd(),"index.html"))
})

let tokens = {}

function r(l=6){
  return [...Array(l)].map(()=> "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"[Math.floor(Math.random()*62)]).join("")
}

function xor(s,k){
  return Buffer.from([...s].map((c,i)=>c.charCodeAt(0)^k.charCodeAt(i%k.length))).toString("base64")
}

function obf(code){
  let key = r(8)
  return {enc:xor(code,key),key}
}

app.post("/api/create",(req,res)=>{
  let {code,name} = req.body
  if(!code) return res.sendStatus(400)

  if(!name || name.length<3) name = r()

  let id = r(10)
  let {enc,key} = obf(code)

  fs.writeFileSync(path.join(db,`${id}.json`),JSON.stringify({enc,key}))

  res.json({link:`https://your-render-url/${id}`})
})

app.get("/api/token/:id",(req,res)=>{
  let id = req.params.id
  let file = path.join(db,`${id}.json`)
  if(!fs.existsSync(file)) return res.send("404")

  let t = r(20)
  tokens[t] = {
    id,
    ip: req.headers["x-forwarded-for"] || req.socket.remoteAddress,
    exp: Date.now()+5000
  }

  res.send(t)
})

app.get("/api/load/:id",(req,res)=>{
  let t = req.query.t
  let data = tokens[t]

  if(!data) return res.send("blocked")
  if(data.exp < Date.now()) return res.send("blocked")

  let ip = req.headers["x-forwarded-for"] || req.socket.remoteAddress
  if(data.ip !== ip) return res.send("blocked")

  delete tokens[t]

  let file = path.join(db,`${data.id}.json`)
  if(!fs.existsSync(file)) return res.send("404")

  let {enc,key} = JSON.parse(fs.readFileSync(file,"utf8"))

  let mid = enc.length>>1
  let p1 = enc.slice(0,mid)
  let p2 = enc.slice(mid)

  let payload = `
local k="${key}"
local a="${p1}"
local b="${p2}"
local d=a..b

local function x(s,k)
  local b=game:GetService("HttpService"):Base64Decode(s)
  local r=""
  for i=1,#b do
    r=r..string.char(string.byte(b,i)~string.byte(k,((i-1)%#k)+1))
  end
  return r
end

loadstring(x(d,k))()
`

  res.setHeader("content-type","text/plain")
  res.send(payload)
})

app.get("/:id",(req,res)=>{
  let id = req.params.id

  let loader = `
local b="https://your-render-url"
local t=game:HttpGet(b.."/api/token/${id}")
local s=game:HttpGet(b.."/api/load/${id}?t="..t)
loadstring(s)()
`

  res.setHeader("content-type","text/plain")
  res.send(loader)
})

app.listen(process.env.PORT || 3000)
