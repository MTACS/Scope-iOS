#define SDK_PATH @"/var/mobile/Library/Preferences/Scope/"

@interface OBButtonTray : UIView
@property (nonatomic, retain) UIVisualEffectView *effectView;
- (void)addButton:(id)arg1;
- (void)addCaptionText:(id)arg1;;
@end

@interface OBTrayButton : UIButton
+ (id)buttonWithType:(long long)arg1 ;
+ (double)standardHeight;
- (CGSize)intrinsicContentSize;
- (void)setTitle:(id)arg1 forState:(unsigned long long)arg2 ;
- (void)traitCollectionDidChange:(id)arg1 ;
- (void)layoutSubviews;
- (id)_fontTextStyle;
@end

@interface OBBoldTrayButton : UIButton
- (void)setTitle:(id)arg1 forState:(unsigned long long)arg2;
+ (id)buttonWithType:(long long)arg1;
@end

@interface OBWelcomeController : UIViewController
@property (nonatomic, retain) UIView *viewIfLoaded;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (assign, nonatomic) BOOL _shouldInlineButtontray;   
- (BOOL)_shouldInlineButtontray;
- (OBButtonTray *)buttonTray;
- (id)initWithTitle:(id)arg1 detailText:(id)arg2 icon:(id)arg3;
- (void)addBulletedListItemWithTitle:(id)arg1 description:(id)arg2 image:(id)arg3;
@end