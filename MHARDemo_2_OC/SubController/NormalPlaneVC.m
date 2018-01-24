//
//  NormalPlaneVC.m
//  MHARDemo_2_OC
//
//  Created by 111 on 2018/1/18.
//  Copyright © 2018年 111. All rights reserved.
//

#import "NormalPlaneVC.h"
#import <ARKit/ARKit.h>
#import <SceneKit/SceneKit.h>

@interface NormalPlaneVC ()

@property (nonatomic, strong)ARSCNView *arSCNView;

@property (nonatomic, strong)ARSession *arSession;

@property (nonatomic, strong)ARConfiguration *arConfiguration;

@end

@implementation NormalPlaneVC

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
    
    [self addStaticPlane];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self addStaticPlane];
}

- (void)addStaticPlane{
    SCNScene *scene = [SCNScene sceneNamed:@"Model.scnassets/ship.scn"];
    
    SCNNode *shipNode = scene.rootNode.childNodes[0];
    
    [self.arSCNView.scene.rootNode addChildNode:shipNode];
}


#pragma mark - lazyLoading
- (ARSCNView *)arSCNView{
    if (!_arSCNView) {
        _arSCNView = [[ARSCNView alloc] initWithFrame:self.view.bounds];
        _arSCNView.session = self.arSession;
    }
    return _arSCNView;
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

- (ARSession *)arSession{
    if (!_arSession) {
        _arSession = [[ARSession alloc] init];
    }
    return _arSession;
}
@end
