//
//  RecognitionPlaneViewController.m
//  MHARDemo_2_OC
//
//  Created by 111 on 2018/1/23.
//  Copyright © 2018年 111. All rights reserved.
//

#import "RecognitionPlaneViewController.h"
#import <ARKit/ARKit.h>
#import <SceneKit/SceneKit.h>

@interface RecognitionPlaneViewController ()<ARSCNViewDelegate,ARSessionDelegate>
@property (nonatomic, strong)ARSCNView *arSCNView;

@property (nonatomic, strong)ARSession *arSession;

@property (nonatomic, strong)ARConfiguration *arConfiguration;

@property (nonatomic, strong)NSMutableDictionary *planeDictionary;

@property (nonatomic, strong)NSMutableDictionary *nodeDictionary;
@end

@implementation RecognitionPlaneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self.view addSubview:self.arSCNView];
    
    [self.arSession runWithConfiguration:self.arConfiguration];
}
#pragma mark - ARSCNViewDelegate
/**
 当新的节点映射到指定锚点时调用

 @param renderer 渲染画面的渲染器
 @param node 新添加的节点
 @param anchor 节点映射到的锚点
 */
- (void)renderer:(id<SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor{
    //过滤平面锚点
    if ([anchor isKindOfClass:[ARPlaneAnchor class]]) {
        //实例化为子类
        ARPlaneAnchor *arPlaneAnchor = (ARPlaneAnchor *)anchor;
        
        NSLog(@"center - (%f,%f,%f)",arPlaneAnchor.center.x,arPlaneAnchor.center.y,arPlaneAnchor.center.z);
        NSLog(@"extent - (%f,%f,%f)",arPlaneAnchor.extent.x,arPlaneAnchor.extent.y,arPlaneAnchor.extent.z);

        NSLog(@"添加平面锚点%@",anchor.identifier);
        //arPlaneAnchor.extent代表锚点的坐标控件中平面的范围
        SCNPlane *scnPlane = [SCNPlane planeWithWidth:arPlaneAnchor.extent.x height:arPlaneAnchor.extent.z];
        scnPlane.firstMaterial.diffuse.contents = [UIColor greenColor];
        scnPlane.firstMaterial.transparency = 0.5;
        
        SCNNode *planeNode = [SCNNode nodeWithGeometry:scnPlane];
        [planeNode setPosition:SCNVector3Make(arPlaneAnchor.center.x, 0, arPlaneAnchor.center.z)];
        planeNode.transform = SCNMatrix4MakeRotation(- M_PI_2, 1, 0, 0);
        
        [self.planeDictionary setObject:scnPlane forKey:arPlaneAnchor.identifier];
        [self.nodeDictionary setObject:planeNode forKey:arPlaneAnchor.identifier];
        
        [node addChildNode:planeNode];
    }
}

- (void)renderer:(id<SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor{
    if ([self.planeDictionary objectForKey:anchor.identifier] && [self.nodeDictionary objectForKey:anchor.identifier]) {
        NSLog(@"更新节点%@",anchor.identifier);
        ARPlaneAnchor *planeAnchor = (ARPlaneAnchor *)anchor;
        SCNNode *scnNode = [self.nodeDictionary objectForKey:anchor.identifier];
        SCNPlane *scnPlane = [self.planeDictionary objectForKey:anchor.identifier];
        
        scnPlane.width = planeAnchor.extent.x;
        scnPlane.height = planeAnchor.extent.z;
        
        scnNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z);
    }
}

- (void)renderer:(id<SCNSceneRenderer>)renderer didRemoveNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor{
    NSLog(@"移除节点%@",anchor.identifier);
    [self.nodeDictionary removeObjectForKey:anchor.identifier];
    [self.planeDictionary removeObjectForKey:anchor.identifier];
}
#pragma mark - ARSessionDelegate
/**
 有新锚点添加至session中时调用

 @param session 正在运行的session
 @param anchors 被添加的锚点数组
 */
- (void)session:(ARSession *)session didAddAnchors:(NSArray<ARAnchor *> *)anchors{
    if ([anchors isKindOfClass:[ARPlaneAnchor class]]) {
        NSLog(@"ARSessionDelegate - 平面锚点添加至Session");
    }
}

#pragma mark - lazyLoading
- (ARSCNView *)arSCNView{
    if (!_arSCNView) {
        _arSCNView = [[ARSCNView alloc] initWithFrame:self.view.bounds];
        _arSCNView.delegate = self;
        _arSCNView.session = self.arSession;
        _arSCNView.debugOptions = ARSCNDebugOptionShowFeaturePoints;
    }
    return _arSCNView;
}

- (ARSession *)arSession{
    if (!_arSession) {
        _arSession = [[ARSession alloc] init];
        _arSession.delegate = self;
    }
    return _arSession;
}

- (ARConfiguration *)arConfiguration{
    if (!_arConfiguration) {
        ARWorldTrackingConfiguration *arWTConfiguration = [[ARWorldTrackingConfiguration alloc] init];
        arWTConfiguration.planeDetection = ARPlaneDetectionHorizontal;
        arWTConfiguration.lightEstimationEnabled = YES;
        _arConfiguration = arWTConfiguration;
    }
    return _arConfiguration;
}

- (NSMutableDictionary *)planeDictionary{
    if (!_planeDictionary) {
        _planeDictionary = [[NSMutableDictionary alloc] init];
    }
    return _planeDictionary;
}

- (NSMutableDictionary *)nodeDictionary{
    if (!_nodeDictionary) {
        _nodeDictionary = [[NSMutableDictionary alloc] init];
    }
    return _nodeDictionary;
}
@end
