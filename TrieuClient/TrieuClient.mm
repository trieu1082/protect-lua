#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

// ============================================================
//  CLIENT MADE BY TRIEU - PREMIUM UI DYLIB
//  Hiện frame UI đẹp bo góc khi inject vào app
//  Nút Đóng -> đóng frame + notify "Chúc bạn chs vui vẻ"
// ============================================================

static UIWindow *trieuWindow = nil;
static UIView *dimView = nil;
static UIView *cardView = nil;

// ---------- Toast Notify ----------
static void showToast(NSString *msg) {
    UIWindow *keyWindow = nil;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *w in scene.windows) {
                    if (w.isKeyWindow) { keyWindow = w; break; }
                }
            }
        }
    }
    if (!keyWindow) keyWindow = [UIApplication sharedApplication].keyWindow;
    if (!keyWindow) keyWindow = [UIApplication sharedApplication].windows.firstObject;
    if (!keyWindow) return;

    UIView *container = keyWindow;

    UILabel *toast = [[UILabel alloc] init];
    toast.text = msg;
    toast.textColor = [UIColor whiteColor];
    toast.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.85];
    toast.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    toast.textAlignment = NSTextAlignmentCenter;
    toast.numberOfLines = 0;
    toast.alpha = 0;
    toast.layer.cornerRadius = 14;
    toast.clipsToBounds = YES;
    toast.layer.shadowColor = [UIColor blackColor].CGColor;
    toast.layer.shadowOpacity = 0.25;
    toast.layer.shadowRadius = 8;
    toast.layer.shadowOffset = CGSizeMake(0, 4);

    // padding
    CGSize maxSize = CGSizeMake(container.bounds.size.width - 40, 100);
    CGSize textSize = [msg boundingRectWithSize:maxSize
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{NSFontAttributeName: toast.font}
                                          context:nil].size;
    CGFloat w = MIN(maxSize.width, textSize.width + 40);
    CGFloat h = textSize.height + 20;
    CGFloat x = (container.bounds.size.width - w) / 2.0;
    CGFloat y = container.bounds.size.height - h - 50 - container.safeAreaInsets.bottom;

    toast.frame = CGRectMake(x, y, w, h);
    // thêm padding bằng cách inset? dùng label với center
    // để đẹp hơn, cho layer
    [container addSubview:toast];

    // icon trái nếu muốn
    // Animation
    [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
        toast.alpha = 1;
        toast.transform = CGAffineTransformMakeTranslation(0, -6);
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.35 animations:^{
                toast.alpha = 0;
                toast.transform = CGAffineTransformMakeTranslation(0, 10);
            } completion:^(BOOL f){
                [toast removeFromSuperview];
            }];
        });
    }];
}

// ---------- Close Action ----------
static void closeTrieuUI(void) {
    if (!trieuWindow) return;

    [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:0.85 initialSpringVelocity:0.6 options:UIViewAnimationOptionCurveEaseIn animations:^{
        dimView.alpha = 0;
        cardView.transform = CGAffineTransformMakeScale(0.85, 0.85);
        cardView.alpha = 0;
    } completion:^(BOOL finished) {
        trieuWindow.hidden = YES;
        [trieuWindow resignKeyWindow];
        trieuWindow = nil;
        dimView = nil;
        cardView = nil;

        // Notify sau khi đóng
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            showToast(@"Chúc bạn chs vui vẻ 🎮✨");
        });

        // Nếu muốn alert thay vì toast thì bật đoạn này:
        // UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Tạm biệt 👋" message:@"Chúc bạn chs vui vẻ 🎮" preferredStyle:UIAlertControllerStyleAlert];
        // [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        // [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    }];
}

// ---------- Show UI ----------
static void showTrieuUI(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        // Tránh hiện 2 lần
        if (trieuWindow && !trieuWindow.hidden) return;

        UIScreen *screen = [UIScreen mainScreen];
        CGRect bounds = screen.bounds;

        // --- Window ---
        // iOS 13+ Scene support
        if (@available(iOS 13.0, *)) {
            UIWindowScene *scene = nil;
            for (UIWindowScene *s in [UIApplication sharedApplication].connectedScenes) {
                if ([s isKindOfClass:[UIWindowScene class]] && s.activationState == UISceneActivationStateForegroundActive) {
                    scene = s; break;
                }
            }
            if (!scene) {
                for (UIWindowScene *s in [UIApplication sharedApplication].connectedScenes) {
                    if ([s isKindOfClass:[UIWindowScene class]]) { scene = s; break; }
                }
            }
            if (scene) {
                trieuWindow = [[UIWindow alloc] initWithWindowScene:scene];
            } else {
                trieuWindow = [[UIWindow alloc] initWithFrame:bounds];
            }
        } else {
            trieuWindow = [[UIWindow alloc] initWithFrame:bounds];
        }

        trieuWindow.backgroundColor = [UIColor clearColor];
        trieuWindow.windowLevel = UIWindowLevelAlert + 100;
        trieuWindow.hidden = NO;
        [trieuWindow makeKeyAndVisible];

        UIView *rootView = trieuWindow;
        if (@available(iOS 13.0, *)) {
            // với windowScene thì cần rootViewController
            UIViewController *vc = [[UIViewController alloc] init];
            vc.view.backgroundColor = [UIColor clearColor];
            trieuWindow.rootViewController = vc;
            rootView = vc.view;
        }

        // --- Dim background với blur ---
        dimView = [[UIView alloc] initWithFrame:bounds];
        dimView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.45];
        dimView.alpha = 0;
        [rootView addSubview:dimView];

        // Thêm blur view cho đẹp
        if (@available(iOS 8.0, *)) {
            UIVisualEffectView *blur = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
            blur.frame = dimView.bounds;
            blur.alpha = 0.45;
            blur.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [dimView addSubview:blur];
        }

        // Tap dim để đóng
        UITapGestureRecognizer *tapDim = [[UITapGestureRecognizer alloc] initWithTarget:[NSObject class] action:NULL];
        // dùng block target
        dimView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        [dimView addGestureRecognizer:tap];
        // dùng closure qua objc association - đơn giản just add target via block
        // We use UITapGestureRecognizer with custom handler via add target function
        // Tạo helper object
        // Để đơn giản: không dùng tap dim đóng, chỉ nút đóng mới đóng (tránh nhầm)
        // Nếu muốn đóng khi tap nền thì uncomment:
        // [tap addTarget:[NSBlockOperation blockOperationWithBlock:^{ closeTrieuUI(); }] action:@selector(main)];

        // --- Card View - Bo góc 24 ---
        CGFloat cardW = MIN(bounds.size.width - 40, 340);
        CGFloat cardH = 360;
        CGFloat cardX = (bounds.size.width - cardW)/2;
        CGFloat cardY = (bounds.size.height - cardH)/2;

        cardView = [[UIView alloc] initWithFrame:CGRectMake(cardX, cardY, cardW, cardH)];
        cardView.backgroundColor = [UIColor whiteColor];
        cardView.layer.cornerRadius = 24;
        cardView.layer.cornerCurve = kCACornerCurveContinuous; // iOS 13+ continuous corner
        cardView.clipsToBounds = NO;
        cardView.alpha = 0;
        cardView.transform = CGAffineTransformMakeScale(0.82, 0.82);
        // Shadow
        cardView.layer.shadowColor = [UIColor blackColor].CGColor;
        cardView.layer.shadowOpacity = 0.22;
        cardView.layer.shadowRadius = 20;
        cardView.layer.shadowOffset = CGSizeMake(0, 12);
        cardView.layer.masksToBounds = NO;

        // Gradient border effect (fake border bằng view bên trong)
        UIView *borderGradientView = [[UIView alloc] initWithFrame:cardView.bounds];
        borderGradientView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        borderGradientView.layer.cornerRadius = 24;
        borderGradientView.layer.cornerCurve = kCACornerCurveContinuous;
        borderGradientView.clipsToBounds = YES;
        borderGradientView.userInteractionEnabled = NO;
        // sẽ thêm gradient layer sau

        [rootView addSubview:cardView];

        // Clip content view inside card
        UIView *clipContent = [[UIView alloc] initWithFrame:cardView.bounds];
        clipContent.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        clipContent.layer.cornerRadius = 24;
        clipContent.layer.cornerCurve = kCACornerCurveContinuous;
        clipContent.clipsToBounds = YES;
        clipContent.backgroundColor = [UIColor whiteColor];
        [cardView addSubview:clipContent];
        [cardView bringSubviewToFront:clipContent];

        // ---------- HEADER GRADIENT ----------
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cardW, 132)];
        headerView.clipsToBounds = YES;
        [clipContent addSubview:headerView];

        CAGradientLayer *headerGradient = [CAGradientLayer layer];
        headerGradient.frame = headerView.bounds;
        headerGradient.colors = @[
            (id)[UIColor colorWithRed:0.49 green:0.23 blue:1.0 alpha:1.0].CGColor, // #7C3AED
            (id)[UIColor colorWithRed:0.93 green:0.28 blue:0.59 alpha:1.0].CGColor, // #EC4899
            (id)[UIColor colorWithRed:0.99 green:0.64 blue:0.07 alpha:1.0].CGColor  // #F59E0B
        ];
        headerGradient.startPoint = CGPointMake(0, 0);
        headerGradient.endPoint = CGPointMake(1, 1);
        headerGradient.locations = @[@0.0, @0.55, @1.0];
        [headerView.layer insertSublayer:headerGradient atIndex:0];
        headerGradient.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;

        // Pattern overlay dots in header
        UIView *dotsOverlay = [[UIView alloc] initWithFrame:headerView.bounds];
        dotsOverlay.backgroundColor = [UIColor clearColor];
        dotsOverlay.alpha = 0.12;
        dotsOverlay.userInteractionEnabled = NO;
        [headerView addSubview:dotsOverlay];

        // Icon vòng tròn 64x64 ở header
        CGFloat iconSize = 72;
        UIView *iconWrap = [[UIView alloc] initWithFrame:CGRectMake((cardW - iconSize)/2, 18, iconSize, iconSize)];
        iconWrap.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.18];
        iconWrap.layer.cornerRadius = iconSize/2;
        iconWrap.clipsToBounds = NO;
        iconWrap.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.35].CGColor;
        iconWrap.layer.borderWidth = 1.5;
        // blur trong icon
        if (@available(iOS 8.0, *)) {
            UIVisualEffectView *iconBlur = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
            iconBlur.frame = iconWrap.bounds;
            iconBlur.layer.cornerRadius = iconSize/2;
            iconBlur.clipsToBounds = YES;
            iconBlur.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [iconWrap addSubview:iconBlur];
        }
        [headerView addSubview:iconWrap];

        // Icon label 👑
        UILabel *iconLabel = [[UILabel alloc] initWithFrame:iconWrap.bounds];
        iconLabel.text = @"👑";
        iconLabel.font = [UIFont systemFontOfSize:34];
        iconLabel.textAlignment = NSTextAlignmentCenter;
        iconLabel.backgroundColor = [UIColor clearColor];
        [iconWrap addSubview:iconLabel];

        // Shadow cho icon
        iconWrap.layer.shadowColor = [UIColor blackColor].CGColor;
        iconWrap.layer.shadowOpacity = 0.25;
        iconWrap.layer.shadowRadius = 10;
        iconWrap.layer.shadowOffset = CGSizeMake(0, 6);

        // Text "CLIENT MADE BY"
        UILabel *smallTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, cardW, 14)];
        smallTitle.text = @"✨  CLIENT MADE BY  ✨";
        smallTitle.font = [UIFont systemFontOfSize:10 weight:UIFontWeightBold];
        smallTitle.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.92];
        smallTitle.textAlignment = NSTextAlignmentCenter;
        smallTitle.layer.shadowColor = [UIColor blackColor].CGColor;
        smallTitle.layer.shadowOpacity = 0.25;
        smallTitle.layer.shadowRadius = 2;
        smallTitle.layer.shadowOffset = CGSizeMake(0, 1);
        [headerView addSubview:smallTitle];

        // ---------- BODY ----------
        // Title TRIEU
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 148, cardW-32, 32)];
        titleLabel.text = @"TRIỆU";
        titleLabel.font = [UIFont systemFontOfSize:34 weight:UIFontWeightHeavy];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor colorWithRed:0.11 green:0.11 blue:0.12 alpha:1.0];
        // gradient text effect via shadow? keep simple
        [clipContent addSubview:titleLabel];

        // Subtitle
        UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 182, cardW-32, 20)];
        subLabel.text = @"Premium Client  •  v1.0";
        subLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
        subLabel.textColor = [UIColor colorWithWhite:0.55 alpha:1.0];
        subLabel.textAlignment = NSTextAlignmentCenter;
        [clipContent addSubview:subLabel];

        // Divider line với gradient
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(24, 212, cardW-48, 1)];
        line.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1.0];
        // thêm gradient line overlay
        CAGradientLayer *lineGrad = [CAGradientLayer layer];
        lineGrad.frame = CGRectMake(0, 0, cardW-48, 1);
        lineGrad.colors = @[
            (id)[UIColor clearColor].CGColor,
            (id)[UIColor colorWithRed:0.49 green:0.23 blue:1.0 alpha:0.15].CGColor,
            (id)[UIColor colorWithRed:0.93 green:0.28 blue:0.59 alpha:0.15].CGColor,
            (id)[UIColor clearColor].CGColor
        ];
        lineGrad.startPoint = CGPointMake(0, 0.5);
        lineGrad.endPoint = CGPointMake(1, 0.5);
        [line.layer addSublayer:lineGrad];
        [clipContent addSubview:line];

        // Feature box - bo góc 14
        UIView *featureBox = [[UIView alloc] initWithFrame:CGRectMake(16, 226, cardW-32, 52)];
        featureBox.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.98 alpha:1.0];
        featureBox.layer.cornerRadius = 14;
        featureBox.layer.cornerCurve = kCACornerCurveContinuous;
        featureBox.clipsToBounds = YES;
        featureBox.layer.borderColor = [UIColor colorWithWhite:0.92 alpha:1.0].CGColor;
        featureBox.layer.borderWidth = 1;
        [clipContent addSubview:featureBox];

        // dot status
        UIView *dot = [[UIView alloc] initWithFrame:CGRectMake(12, 20, 10, 10)];
        dot.backgroundColor = [UIColor colorWithRed:0.13 green:0.77 blue:0.37 alpha:1.0];
        dot.layer.cornerRadius = 5;
        dot.clipsToBounds = YES;
        // glow
        dot.layer.shadowColor = [UIColor colorWithRed:0.13 green:0.77 blue:0.37 alpha:1.0].CGColor;
        dot.layer.shadowOpacity = 0.6;
        dot.layer.shadowRadius = 6;
        dot.layer.shadowOffset = CGSizeZero;
        [featureBox addSubview:dot];

        // pulse animation cho dot
        CABasicAnimation *pulse = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        pulse.fromValue = @1.0;
        pulse.toValue = @1.35;
        pulse.duration = 0.9;
        pulse.autoreverses = YES;
        pulse.repeatCount = HUGE_VALF;
        pulse.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [dot.layer addAnimation:pulse forKey:@"pulse"];

        UILabel *featTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, 10, featureBox.bounds.size.width-42, 16)];
        featTitle.text = @"Đã inject thành công";
        featTitle.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
        featTitle.textColor = [UIColor colorWithRed:0.11 green:0.11 blue:0.12 alpha:1.0];
        [featureBox addSubview:featTitle];

        UILabel *featSub = [[UILabel alloc] initWithFrame:CGRectMake(30, 26, featureBox.bounds.size.width-42, 14)];
        featSub.text = @"Sẵn sàng sử dụng • Chúc bạn chơi vui vẻ!";
        featSub.font = [UIFont systemFontOfSize:11 weight:UIFontWeightRegular];
        featSub.textColor = [UIColor colorWithWhite:0.55 alpha:1.0];
        [featureBox addSubview:featSub];

        // ---------- NÚT ĐÓNG - Gradient Bo góc 14 ----------
        CGFloat btnY = 294;
        CGFloat btnH = 48;
        UIView *btnWrap = [[UIView alloc] initWithFrame:CGRectMake(16, btnY, cardW-32, btnH)];
        btnWrap.layer.cornerRadius = 14;
        btnWrap.layer.cornerCurve = kCACornerCurveContinuous;
        btnWrap.clipsToBounds = YES;
        btnWrap.layer.shadowColor = [UIColor colorWithRed:0.49 green:0.23 blue:1.0 alpha:1.0].CGColor;
        btnWrap.layer.shadowOpacity = 0.35;
        btnWrap.layer.shadowRadius = 10;
        btnWrap.layer.shadowOffset = CGSizeMake(0, 6);
        [clipContent addSubview:btnWrap];

        // Gradient cho nút
        CAGradientLayer *btnGrad = [CAGradientLayer layer];
        btnGrad.frame = btnWrap.bounds;
        btnGrad.cornerRadius = 14;
        btnGrad.colors = @[
            (id)[UIColor colorWithRed:0.49 green:0.23 blue:1.0 alpha:1.0].CGColor,
            (id)[UIColor colorWithRed:0.93 green:0.28 blue:0.59 alpha:1.0].CGColor
        ];
        btnGrad.startPoint = CGPointMake(0, 0.5);
        btnGrad.endPoint = CGPointMake(1, 0.5);
        [btnWrap.layer insertSublayer:btnGrad atIndex:0];

        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        closeBtn.frame = btnWrap.bounds;
        closeBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        closeBtn.backgroundColor = [UIColor clearColor];
        [closeBtn setTitle:@"ĐÓNG  ✕" forState:UIControlStateNormal];
        [closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        closeBtn.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightBold];
        closeBtn.titleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        closeBtn.titleLabel.layer.shadowOpacity = 0.2;
        closeBtn.titleLabel.layer.shadowRadius = 2;
        closeBtn.titleLabel.layer.shadowOffset = CGSizeMake(0, 1);
        closeBtn.layer.cornerRadius = 14;
        [btnWrap addSubview:closeBtn];

        // Highlight effect
        UIView *highlight = [[UIView alloc] initWithFrame:CGRectMake(0, 0, btnWrap.bounds.size.width, btnWrap.bounds.size.height/2)];
        highlight.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.12];
        highlight.userInteractionEnabled = NO;
        highlight.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [btnWrap insertSubview:highlight aboveSubview:btnGrad];

        // Action
        // Dùng UIControlEventTouchUpInside với block via helper
        // Tạo target bằng cách dùng NSInvocation? Đơn giản: dùng addTarget với function C
        // Vì không có self, dùng trick: tạo một object holder
        // Để đơn giản nhất: dùng UIButton target là nil và dùng classic
        // Chúng ta sẽ add target bằng runtime: tạo một NSObject subclass inline bằng block
        // Workaround: dùng UIControl addAction for iOS 14+, fallback cũ

        // iOS 14+ UIAction
        if (@available(iOS 14.0, *)) {
            UIAction *act = [UIAction actionWithTitle:@"" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
                // scale tap effect
                [UIView animateWithDuration:0.08 animations:^{
                    btnWrap.transform = CGAffineTransformMakeScale(0.96, 0.96);
                } completion:^(BOOL f){
                    [UIView animateWithDuration:0.12 animations:^{
                        btnWrap.transform = CGAffineTransformIdentity;
                    }];
                    closeTrieuUI();
                }];
            }];
            [closeBtn addAction:act forControlEvents:UIControlEventTouchUpInside];
        } else {
            // fallback: dùng target object giữ
            // Tạo một helper class động
            // Dùng performSelector after? Để đơn giản dùng addTarget với block via associated object
            // Ở đây ta dùng classic: tạo một singleton helper
            static id helper = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                helper = [[NSObject alloc] init];
                // add method via runtime
                // Instead we just swizzle? Simpler: use UIButton's touchUpInside via notification
                // Thực tế trên iOS cũ vẫn chạy được nếu dùng addTarget với closure bằng cách tạo category
                // Tạo class TrieuBtnHelper
            });
            // Fallback đơn giản: dùng delay closure qua dispatch
            // Vì không thể add C function làm selector, ta sẽ dùng timer
            // Thay vì vậy, override bằng cách thêm gesture
            // Dùng workaround: set tag và check
            closeBtn.tag = 999;
            // Thêm target là một object có method closeTrieuUIWrapper
            // Tạo class helper tạm
            Class hClass = NSClassFromString(@"TrieuBtnHelper");
            if (!hClass) {
                hClass = objc_allocateClassPair([NSObject class], "TrieuBtnHelper", 0);
                class_addMethod(hClass, @selector(onTap:), (IMP)[](id self, SEL _cmd, UIButton *sender){
                    [UIView animateWithDuration:0.08 animations:^{
                        // find btnWrap via superview
                        sender.superview.transform = CGAffineTransformMakeScale(0.96, 0.96);
                    } completion:^(BOOL f){
                        [UIView animateWithDuration:0.12 animations:^{
                            sender.superview.transform = CGAffineTransformIdentity;
                        }];
                        closeTrieuUI();
                    }];
                }, "v@:@");
                objc_registerClassPair(hClass);
                helper = [[hClass alloc] init];
            }
            [closeBtn addTarget:helper action:@selector(onTap:) forControlEvents:UIControlEventTouchUpInside];
        }

        // Nút đóng nhỏ góc trên phải (X) - optional
        UIButton *xBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        xBtn.frame = CGRectMake(cardW-34, 10, 24, 24);
        xBtn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.18];
        xBtn.layer.cornerRadius = 12;
        xBtn.clipsToBounds = YES;
        if (@available(iOS 8.0, *)) {
            UIVisualEffectView *xBlur = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
            xBlur.frame = xBtn.bounds;
            xBlur.layer.cornerRadius = 12;
            xBlur.clipsToBounds = YES;
            xBlur.userInteractionEnabled = NO;
            xBlur.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [xBtn insertSubview:xBlur atIndex:0];
        }
        [xBtn setTitle:@"✕" forState:UIControlStateNormal];
        [xBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        xBtn.titleLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightBold];
        xBtn.alpha = 0.92;
        [headerView addSubview:xBtn];
        if (@available(iOS 14.0, *)) {
            UIAction *xAct = [UIAction actionWithTitle:@"" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull a){
                closeTrieuUI();
            }];
            [xBtn addAction:xAct forControlEvents:UIControlEventTouchUpInside];
        } else {
            Class hClass = NSClassFromString(@"TrieuBtnHelper");
            id helper2 = [[hClass alloc] init];
            if (hClass) [xBtn addTarget:helper2 action:@selector(onTap:) forControlEvents:UIControlEventTouchUpInside];
        }

        // ---------- ANIMATION VÀO ----------
        // Haptics
        if (@available(iOS 10.0, *)) {
            UIImpactFeedbackGenerator *gen = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
            [gen prepare];
            [gen impactOccurred];
        }

        [UIView animateWithDuration:0.45 delay:0 usingSpringWithDamping:0.78 initialSpringVelocity:0.6 options:UIViewAnimationOptionCurveEaseOut animations:^{
            dimView.alpha = 1;
            cardView.alpha = 1;
            cardView.transform = CGAffineTransformIdentity;
        } completion:nil];

        // Shimmer nhẹ cho icon
        CABasicAnimation *shimmer = [CABasicAnimation animationWithKeyPath:@"opacity"];
        shimmer.fromValue = @0.92;
        shimmer.toValue = @1.0;
        shimmer.duration = 1.4;
        shimmer.autoreverses = YES;
        shimmer.repeatCount = HUGE_VALF;
        [iconWrap.layer addAnimation:shimmer forKey:@"shimmer"];

        // Nút pulse nhẹ
        CABasicAnimation *btnPulse = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        btnPulse.fromValue = @1.0;
        btnPulse.toValue = @1.015;
        btnPulse.duration = 1.2;
        btnPulse.autoreverses = YES;
        btnPulse.repeatCount = HUGE_VALF;
        btnPulse.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [btnWrap.layer addAnimation:btnPulse forKey:@"btnPulse"];
    });
}

// ---------- Auto show sau khi app launch ----------
__attribute__((constructor))
static void trieu_constructor(void) {
    // Delay 0.8s sau khi inject
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // Nếu app chưa có window thì đợi tiếp 0.5s rồi thử lại
        if ([UIApplication sharedApplication].keyWindow == nil && [UIApplication sharedApplication].windows.count == 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                showTrieuUI();
            });
        } else {
            showTrieuUI();
        }
    });

    // Lắng nghe khi app vào foreground thì có thể show lại (optional)
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        // Nếu user muốn chỉ hiện 1 lần thì comment dòng dưới
        // Nếu đã đóng rồi thì không hiện lại nữa
        // Để hiện lại mỗi lần foreground thì uncomment:
        // if (!trieuWindow || trieuWindow.hidden) showTrieuUI();
    }];
}

// Cho phép gọi thủ công từ tweak khác: void showTrieuClient(void)
__attribute__((visibility("default")))
void showTrieuClient(void) {
    showTrieuUI();
}
