#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
static UIWindow *W;
static UIView *D,*C;
static void Toast(NSString *m){
    UIWindow *k=nil;
    if(@available(iOS 13,*)){
        for(UIWindowScene *s in UIApplication.sharedApplication.connectedScenes){
            if([s isKindOfClass:[UIWindowScene class]]&&s.activationState==UISceneActivationStateForegroundActive){
                for(UIWindow *w in ((UIWindowScene*)s).windows)if(w.isKeyWindow){k=w;break;}
                if(k)break;
            }
        }
    }
    if(!k)k=UIApplication.sharedApplication.keyWindow;
    if(!k)k=UIApplication.sharedApplication.windows.firstObject;
    if(!k)return;
    UILabel *t=[[UILabel alloc]init];
    t.text=m;t.textColor=UIColor.whiteColor;
    t.backgroundColor=[UIColor.blackColor colorWithAlphaComponent:0.85];
    t.font=[UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    t.textAlignment=NSTextAlignmentCenter;t.numberOfLines=0;t.alpha=0;
    t.layer.cornerRadius=14;t.clipsToBounds=YES;
    t.layer.shadowColor=UIColor.blackColor.CGColor;t.layer.shadowOpacity=0.25;t.layer.shadowRadius=8;t.layer.shadowOffset=CGSizeMake(0,4);
    CGSize max=CGSizeMake(k.bounds.size.width-40,100);
    CGSize s=[m boundingRectWithSize:max options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:t.font} context:nil].size;
    CGFloat w=MIN(max.width,s.width+40),h=s.height+20,x=(k.bounds.size.width-w)/2,y=k.bounds.size.height-h-50-k.safeAreaInsets.bottom;
    t.frame=CGRectMake(x,y,w,h);[k addSubview:t];
    [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.5 options:0 animations:^{t.alpha=1;t.transform=CGAffineTransformMakeTranslation(0,-6);} completion:^(BOOL f){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,2*NSEC_PER_SEC),dispatch_get_main_queue(),^{[UIView animateWithDuration:0.35 animations:^{t.alpha=0;t.transform=CGAffineTransformMakeTranslation(0,10);} completion:^(BOOL x){[t removeFromSuperview];}];});
    }];
}
static void Close(){
    if(!W)return;
    [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:0.85 initialSpringVelocity:0.6 options:0 animations:^{D.alpha=0;C.transform=CGAffineTransformMakeScale(0.85,0.85);C.alpha=0;} completion:^(BOOL f){
        W.hidden=YES;[W resignKeyWindow];W=nil;D=nil;C=nil;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,0.15*NSEC_PER_SEC),dispatch_get_main_queue(),^{Toast(@"Chúc bạn chs vui vẻ \U0001F3AE\U00002728");});
    }];
}
static void Show(){
    dispatch_async(dispatch_get_main_queue(),^{
        if(W&&!W.hidden)return;
        CGRect b=UIScreen.mainScreen.bounds;
        if(@available(iOS 13,*)){
            UIWindowScene *sc=nil;
            for(UIWindowScene *s in UIApplication.sharedApplication.connectedScenes)if([s isKindOfClass:[UIWindowScene class]]&&s.activationState==UISceneActivationStateForegroundActive){sc=s;break;}
            if(!sc)for(UIWindowScene *s in UIApplication.sharedApplication.connectedScenes)if([s isKindOfClass:[UIWindowScene class]]){sc=s;break;}
            W=sc?[[UIWindow alloc]initWithWindowScene:sc]:[[UIWindow alloc]initWithFrame:b];
        }else W=[[UIWindow alloc]initWithFrame:b];
        W.backgroundColor=UIColor.clearColor;W.windowLevel=UIWindowLevelAlert+100;W.hidden=NO;[W makeKeyAndVisible];
        UIView *r=W;
        if(@available(iOS 13,*)){
            UIViewController *v=[[UIViewController alloc]init];v.view.backgroundColor=UIColor.clearColor;W.rootViewController=v;r=v.view;
        }
        D=[[UIView alloc]initWithFrame:b];D.backgroundColor=[UIColor.blackColor colorWithAlphaComponent:0.45];D.alpha=0;[r addSubview:D];
        UIVisualEffectView *bl=[[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        bl.frame=D.bounds;bl.alpha=0.45;bl.autoresizingMask=18;[D addSubview:bl];
        CGFloat cw=MIN(b.size.width-40,340),ch=360,cx=(b.size.width-cw)/2,cy=(b.size.height-ch)/2;
        C=[[UIView alloc]initWithFrame:CGRectMake(cx,cy,cw,ch)];
        C.backgroundColor=UIColor.whiteColor;C.layer.cornerRadius=24;C.layer.cornerCurve=kCACornerCurveContinuous;C.clipsToBounds=NO;C.alpha=0;C.transform=CGAffineTransformMakeScale(0.82,0.82);
        C.layer.shadowColor=UIColor.blackColor.CGColor;C.layer.shadowOpacity=0.22;C.layer.shadowRadius=20;C.layer.shadowOffset=CGSizeMake(0,12);[r addSubview:C];
        UIView *c=[[UIView alloc]initWithFrame:C.bounds];c.autoresizingMask=18;c.layer.cornerRadius=24;c.layer.cornerCurve=kCACornerCurveContinuous;c.clipsToBounds=YES;c.backgroundColor=UIColor.whiteColor;[C addSubview:c];
        UIView *h=[[UIView alloc]initWithFrame:CGRectMake(0,0,cw,132)];h.clipsToBounds=YES;[c addSubview:h];
        CAGradientLayer *g=[CAGradientLayer layer];g.frame=h.bounds;
        g.colors=@[(id)[UIColor colorWithRed:0.49 green:0.23 blue:1 alpha:1].CGColor,(id)[UIColor colorWithRed:0.93 green:0.28 blue:0.59 alpha:1].CGColor,(id)[UIColor colorWithRed:0.99 green:0.64 blue:0.07 alpha:1].CGColor];
        g.startPoint=CGPointMake(0,0);g.endPoint=CGPointMake(1,1);g.locations=@[@0,@0.55,@1];[h.layer insertSublayer:g atIndex:0];
        CGFloat s=78;
        UIView *w=[[UIView alloc]initWithFrame:CGRectMake((cw-s)/2,16,s,s)];
        w.backgroundColor=[UIColor.whiteColor colorWithAlphaComponent:0.18];w.layer.cornerRadius=s/2;w.clipsToBounds=YES;
        w.layer.borderColor=[UIColor.whiteColor colorWithAlphaComponent:0.38].CGColor;w.layer.borderWidth=1.6;
        w.layer.shadowColor=UIColor.blackColor.CGColor;w.layer.shadowOpacity=0.28;w.layer.shadowRadius=10;w.layer.shadowOffset=CGSizeMake(0,6);
        UIVisualEffectView *iv=[[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        iv.frame=w.bounds;iv.layer.cornerRadius=s/2;iv.clipsToBounds=YES;iv.autoresizingMask=18;[w addSubview:iv];
        UILabel *e=[[UILabel alloc]initWithFrame:w.bounds];
        e.text=@"\U0001F921";e.font=[UIFont systemFontOfSize:42];e.textAlignment=NSTextAlignmentCenter;e.backgroundColor=UIColor.clearColor;[w addSubview:e];
        [h addSubview:w];
        UILabel *a=[[UILabel alloc]initWithFrame:CGRectMake(0,102,cw,14)];
        a.text=@"\u2728  CLIENT MADE BY  \u2728";a.font=[UIFont systemFontOfSize:10 weight:UIFontWeightBold];a.textColor=[UIColor.whiteColor colorWithAlphaComponent:0.92];a.textAlignment=NSTextAlignmentCenter;
        a.layer.shadowColor=UIColor.blackColor.CGColor;a.layer.shadowOpacity=0.25;a.layer.shadowRadius=2;a.layer.shadowOffset=CGSizeMake(0,1);[h addSubview:a];
        UILabel *t=[[UILabel alloc]initWithFrame:CGRectMake(16,148,cw-32,32)];
        t.text=@"TRIEU";t.font=[UIFont systemFontOfSize:34 weight:UIFontWeightHeavy];t.textAlignment=NSTextAlignmentCenter;
        t.textColor=[UIColor colorWithRed:0.11 green:0.11 blue:0.12 alpha:1];[c addSubview:t];
        UILabel *u=[[UILabel alloc]initWithFrame:CGRectMake(16,182,cw-32,20)];
        u.text=@"Premium Client \u2022 v1.0";u.font=[UIFont systemFontOfSize:12 weight:UIFontWeightMedium];u.textColor=[UIColor colorWithWhite:0.55 alpha:1];u.textAlignment=NSTextAlignmentCenter;[c addSubview:u];
        UIView *l=[[UIView alloc]initWithFrame:CGRectMake(24,212,cw-48,1)];l.backgroundColor=[UIColor colorWithWhite:0.93 alpha:1];[c addSubview:l];
        CAGradientLayer *q=[CAGradientLayer layer];q.frame=CGRectMake(0,0,cw-48,1);
        q.colors=@[(id)UIColor.clearColor.CGColor,(id)[UIColor colorWithRed:0.49 green:0.23 blue:1 alpha:0.15].CGColor,(id)[UIColor colorWithRed:0.93 green:0.28 blue:0.59 alpha:0.15].CGColor,(id)UIColor.clearColor.CGColor];
        q.startPoint=CGPointMake(0,0.5);q.endPoint=CGPointMake(1,0.5);[l.layer addSublayer:q];
        UIView *b2=[[UIView alloc]initWithFrame:CGRectMake(16,226,cw-32,52)];
        b2.backgroundColor=[UIColor colorWithRed:0.97 green:0.97 blue:0.98 alpha:1];b2.layer.cornerRadius=14;b2.layer.cornerCurve=kCACornerCurveContinuous;b2.clipsToBounds=YES;
        b2.layer.borderColor=[UIColor colorWithWhite:0.92 alpha:1].CGColor;b2.layer.borderWidth=1;[c addSubview:b2];
        UIView *d=[[UIView alloc]initWithFrame:CGRectMake(12,20,10,10)];d.backgroundColor=[UIColor colorWithRed:0.13 green:0.77 blue:0.37 alpha:1];d.layer.cornerRadius=5;d.clipsToBounds=YES;
        d.layer.shadowColor=d.backgroundColor.CGColor;d.layer.shadowOpacity=0.6;d.layer.shadowRadius=6;[b2 addSubview:d];
        CABasicAnimation *p=[CABasicAnimation animationWithKeyPath:@"transform.scale"];p.fromValue=@1;p.toValue=@1.35;p.duration=0.9;p.autoreverses=YES;p.repeatCount=HUGE_VALF;p.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];[d.layer addAnimation:p forKey:@"p"];
        UILabel *f=[[UILabel alloc]initWithFrame:CGRectMake(30,10,b2.bounds.size.width-42,16)];f.text=@"\u0110\u00e3 inject th\u00e0nh c\u00f4ng";f.font=[UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];f.textColor=[UIColor colorWithRed:0.11 green:0.11 blue:0.12 alpha:1];[b2 addSubview:f];
        UILabel *y=[[UILabel alloc]initWithFrame:CGRectMake(30,26,b2.bounds.size.width-42,14)];y.text=@"S\u1eb5n s\u00e0ng s\u1eed d\u1ee5ng \u2022 Ch\u00fac b\u1ea1n ch\u01a1i vui v\u1ebb!";y.font=[UIFont systemFontOfSize:11 weight:UIFontWeightRegular];y.textColor=[UIColor colorWithWhite:0.55 alpha:1];[b2 addSubview:y];
        UIView *k2=[[UIView alloc]initWithFrame:CGRectMake(16,294,cw-32,48)];k2.layer.cornerRadius=14;k2.layer.cornerCurve=kCACornerCurveContinuous;k2.clipsToBounds=YES;
        k2.layer.shadowColor=[UIColor colorWithRed:0.49 green:0.23 blue:1 alpha:1].CGColor;k2.layer.shadowOpacity=0.35;k2.layer.shadowRadius=10;k2.layer.shadowOffset=CGSizeMake(0,6);[c addSubview:k2];
        CAGradientLayer *o=[CAGradientLayer layer];o.frame=k2.bounds;o.cornerRadius=14;
        o.colors=@[(id)[UIColor colorWithRed:0.49 green:0.23 blue:1 alpha:1].CGColor,(id)[UIColor colorWithRed:0.93 green:0.28 blue:0.59 alpha:1].CGColor];
        o.startPoint=CGPointMake(0,0.5);o.endPoint=CGPointMake(1,0.5);[k2.layer insertSublayer:o atIndex:0];
        UIButton *btn=[UIButton buttonWithType:0];btn.frame=k2.bounds;btn.autoresizingMask=18;btn.backgroundColor=UIColor.clearColor;[btn setTitle:@"\u0110\u00d3NG  \u2715" forState:0];[btn setTitleColor:UIColor.whiteColor forState:0];
        btn.titleLabel.font=[UIFont systemFontOfSize:15 weight:UIFontWeightBold];btn.titleLabel.layer.shadowColor=UIColor.blackColor.CGColor;btn.titleLabel.layer.shadowOpacity=0.2;btn.titleLabel.layer.shadowRadius=2;btn.titleLabel.layer.shadowOffset=CGSizeMake(0,1);[k2 addSubview:btn];
        UIView *hl=[[UIView alloc]initWithFrame:CGRectMake(0,0,k2.bounds.size.width,24)];hl.backgroundColor=[UIColor.whiteColor colorWithAlphaComponent:0.12];hl.userInteractionEnabled=NO;hl.autoresizingMask=18;[k2 insertSubview:hl aboveSubview:o];
        if(@available(iOS 14,*)){
            UIAction *a2=[UIAction actionWithTitle:@"" image:nil identifier:nil handler:^(__kindof UIAction *x){[UIView animateWithDuration:0.08 animations:^{k2.transform=CGAffineTransformMakeScale(0.96,0.96);} completion:^(BOOL f){[UIView animateWithDuration:0.12 animations:^{k2.transform=CGAffineTransformIdentity;}];Close();}];}];[btn addAction:a2 forControlEvents:UIControlEventTouchUpInside];
        }else{
            Class h2=NSClassFromString(@"TrieuBtnHelper");
            if(!h2){h2=objc_allocateClassPair([NSObject class],"TrieuBtnHelper",0);class_addMethod(h2,@selector(onTap:),(IMP)[](id s,SEL c,UIButton *b){[UIView animateWithDuration:0.08 animations:^{b.superview.transform=CGAffineTransformMakeScale(0.96,0.96);} completion:^(BOOL f){[UIView animateWithDuration:0.12 animations:^{b.superview.transform=CGAffineTransformIdentity;}];Close();}];},"v@:@");objc_registerClassPair(h2);}
            id hp=[[h2 alloc]init];[btn addTarget:hp action:@selector(onTap:) forControlEvents:UIControlEventTouchUpInside];
        }
        UIButton *xb=[UIButton buttonWithType:0];xb.frame=CGRectMake(cw-34,10,24,24);xb.backgroundColor=[UIColor.blackColor colorWithAlphaComponent:0.18];xb.layer.cornerRadius=12;xb.clipsToBounds=YES;xb.alpha=0.92;
        UIVisualEffectView *xv=[[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];xv.frame=xb.bounds;xv.layer.cornerRadius=12;xv.clipsToBounds=YES;xv.userInteractionEnabled=NO;xv.autoresizingMask=18;[xb insertSubview:xv atIndex:0];
        [xb setTitle:@"\u2715" forState:0];[xb setTitleColor:UIColor.whiteColor forState:0];xb.titleLabel.font=[UIFont systemFontOfSize:11 weight:UIFontWeightBold];[h addSubview:xb];
        if(@available(iOS 14,*)){UIAction *xa=[UIAction actionWithTitle:@"" image:nil identifier:nil handler:^(__kindof UIAction *a){Close();}];[xb addAction:xa forControlEvents:UIControlEventTouchUpInside];}
        else{Class h2=NSClassFromString(@"TrieuBtnHelper");if(h2){id hh=[[h2 alloc]init];[xb addTarget:hh action:@selector(onTap:) forControlEvents:UIControlEventTouchUpInside];}}
        if(@available(iOS 10,*)){UIImpactFeedbackGenerator *g=[[UIImpactFeedbackGenerator alloc]initWithStyle:UIImpactFeedbackStyleMedium];[g prepare];[g impactOccurred];}
        [UIView animateWithDuration:0.45 delay:0 usingSpringWithDamping:0.78 initialSpringVelocity:0.6 options:0 animations:^{D.alpha=1;C.alpha=1;C.transform=CGAffineTransformIdentity;} completion:nil];
        CABasicAnimation *sh=[CABasicAnimation animationWithKeyPath:@"opacity"];sh.fromValue=@0.92;sh.toValue=@1;sh.duration=1.4;sh.autoreverses=YES;sh.repeatCount=HUGE_VALF;[w.layer addAnimation:sh forKey:@"s"];
        CABasicAnimation *bp=[CABasicAnimation animationWithKeyPath:@"transform.scale"];bp.fromValue=@1;bp.toValue=@1.015;bp.duration=1.2;bp.autoreverses=YES;bp.repeatCount=HUGE_VALF;bp.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];[k2.layer addAnimation:bp forKey:@"p"];
    });
}
__attribute__((constructor)) static void I(){dispatch_after(dispatch_time(DISPATCH_TIME_NOW,0.8*NSEC_PER_SEC),dispatch_get_main_queue(),^{if(!UIApplication.sharedApplication.keyWindow&&!UIApplication.sharedApplication.windows.count)dispatch_after(dispatch_time(DISPATCH_TIME_NOW,0.7*NSEC_PER_SEC),dispatch_get_main_queue(),^{Show();});else Show();});}
__attribute__((visibility("default"))) void showTrieuClient(){Show();}
