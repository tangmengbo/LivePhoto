//
//  LivePhotoViewController.m
//  Wallpaper
//
//  Created by 薛昭 on 2021/5/7.
//

#import "LivePhotoViewController.h"
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import "LivePhotoMaker.h"

@interface LivePhotoViewController ()

@property (nonatomic, strong) UIButton *button, *button2;
@property (nonatomic, strong) PHLivePhotoView *livePhotoView;

//控件 属性
@property (nonatomic,strong) NSURLSession *session;

@property (nonatomic,strong)NSURL * videoUrl;//通过LivePhotoMaker处理后的本地视频路径
@property (nonatomic,strong)NSURL * imageUrl;//通过LivePhotoMaker处理后的本地图片路径


@end

@implementation LivePhotoViewController

///初始化session
- (NSURLSession *)session{
    if(_session == nil)
    {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    }
    return _session;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.livePhotoView = [[PHLivePhotoView alloc] init];//创建
    self.livePhotoView.contentMode = UIViewContentModeScaleAspectFill;
    self.livePhotoView.clipsToBounds = YES;
    self.livePhotoView.frame = self.view.frame;
    [self.view addSubview:self.livePhotoView];

    
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    self.button.frame = CGRectMake(100, 300, 100, 40);
    [self.button setTitle:@"download" forState:UIControlStateNormal];
    [self.button setBackgroundColor:[UIColor greenColor]];
    [self.view addSubview:self.button];
    [self.button addTarget:self action:@selector(downButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    self.button2.frame = CGRectMake(100, 400, 100, 40);
    [self.button2 setTitle:@"save" forState:UIControlStateNormal];
    [self.button2 setBackgroundColor:[UIColor greenColor]];
    [self.view addSubview:self.button2];
    [self.button2 addTarget:self action:@selector(saveToLibrary) forControlEvents:UIControlEventTouchUpInside];
    self.button2.enabled = NO;
}
-(void)downButtonClick
{
    //NSURL * videoUrl = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"mov"];//本地视频路径
    //[self getLIvePhotoByLocalUrl:videoUrl];//直接调用这个方法不用下载处理
    NSURL * videoUrl=  [NSURL URLWithString:@"https://chatcontent.stylesmo.com//chatcontent//wallpaper//6094bbb5ce239.mp4"];
    [self downloadFileWithUrl:videoUrl];
}
///通过url下载
- (void)downloadFileWithUrl:(NSURL *)url{
    
    
    NSString *documents = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *fileName = [url lastPathComponent];//获取url路径的后缀
    NSString *path = [documents stringByAppendingPathComponent:fileName];//拼接文件绝对路径
    NSFileManager * fileManger = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL voiceDataAlsoExisted = [fileManger fileExistsAtPath:path isDirectory:&isDir];//判断当前文件路径下的文件是否已经下载并缓存到了本地
    if (voiceDataAlsoExisted) {
        
        //如果已经下载了，通过LivePhotoMaker获取处理后的videoUrl和imageUrl
        [self getLIvePhotoByLocalUrl:[NSURL fileURLWithPath:path]];
    }
    else
    {
        //如果没有下载，先下载再通过LivePhotoMaker获取处理后的videoUrl和imageUrl
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:1.0 timeoutInterval:5.0];
        ///下载任务
        [[self.session downloadTaskWithRequest:request]resume];
        
        NSURLSessionDownloadTask *task = [_session downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
            ///[self.hud setLabelText:[NSString stringWithFormat:@"下载成功"]];
            NSFileManager *fileManger = [NSFileManager defaultManager];
            ///沙盒Documents路径
            NSString *documents = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            //拼接文件绝对路径
            NSString *path = [documents stringByAppendingPathComponent:response.suggestedFilename];
            //视频存放到这个位置
            [fileManger moveItemAtURL:location toURL:[NSURL fileURLWithPath:path] error:nil];
            
            [self getLIvePhotoByLocalUrl:[NSURL fileURLWithPath:path]];
            
            // ///保存视频到相册
            // UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        }];
        ///开始下载任务
        [task resume];

    }
}

//保存视频完成之后的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
 if (!error) {
 ///[self.hud setLabelText:[NSString stringWithFormat:@"保存到相册成功"]];
 } else {
 ///[self.hud setLabelText:[NSString stringWithFormat:@"下载失败"]];
 }
 ///[self.hud hide:YES afterDelay:3.0];
}

-(void)getLIvePhotoByLocalUrl:(NSURL *)videoUrl
{
    [LivePhotoMaker makeLivePhotoByLibrary:videoUrl completed:^(NSDictionary * resultDic) {
        if(resultDic) {
            
            self.videoUrl = resultDic[@"MOVPath"];
            self.imageUrl = resultDic[@"JPGPath"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.button2.enabled = YES;

                [PHLivePhoto requestLivePhotoWithResourceFileURLs:@[self.videoUrl ,self.imageUrl] placeholderImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:self.imageUrl]] targetSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height) contentMode:PHImageContentModeAspectFill resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nonnull info) {

                    if (livePhoto!=nil) {

                        [self playLivePhoto:livePhoto];

                    }
                 }];
            });

        }
    }];

}
-(void)playLivePhoto:(PHLivePhoto *)livePhoto
{

    self.livePhotoView.livePhoto = livePhoto;// 赋值
    [self.livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull]; // 播放

}
-(void)saveToLibrary
{
    [LivePhotoMaker saveLivePhotoToAlbumWithMovPath:self.videoUrl ImagePath:self.imageUrl completed:^(BOOL isSuccess) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(isSuccess) {
                NSLog(@"保存成功");
            } else {
                NSLog(@"保存失败");

            }
        });
    }];

}
@end
