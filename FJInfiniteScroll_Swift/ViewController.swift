//
//  ViewController.swift
//  FJInfiniteScroll_Swift
//
//  Created by JYH on 16/6/25.
//  Copyright © 2016年 JYH. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //添加轮播器
        addInfiniteScrollView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    private func addInfiniteScrollView(){
        
        //1.创建无限轮播器
        let infiniteScrollV = FJInfiniteScrollView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 200))
        //2.添加图片资源
        infiniteScrollV.images = [
            NSURL(string: "https://picjumbo.imgix.net/HNCK2415.jpg?q=40&w=1650&sharp=30")!,
            NSURL(string: "https://i0.wp.com/picjumbo.com/wp-content/uploads/HNCK5165.jpg?zoom=2&resize=259%2C148&ssl=1")!,
            NSURL(string: "https://i1.wp.com/picjumbo.com/wp-content/uploads/HNCK5058.jpg?zoom=2&resize=259%2C148&ssl=1")!,
            UIImage(named: "background_1")!,
            "background_2"        ]

        //3.设置页脚颜色
        infiniteScrollV.pageControl.currentPageIndicatorTintColor = UIColor.redColor()
        infiniteScrollV.pageControl.pageIndicatorTintColor = UIColor.grayColor()
        //设置轮播的时间间隔
//        infiniteScrollV.interval = 3
        //设置滚动方向
//        infiniteScrollV.scrollDirection = .FJInfiniteScrollDirectionVertical
        infiniteScrollV.delegate = self
        
        //4.添加到控制器上
        view.addSubview(infiniteScrollV)
    }
}

extension ViewController:FJInfiniteScrollViewDelegate{
    func infiniteScrollView(infiniteScrollView: FJInfiniteScrollView, didClickImageAtIndex: Int) {
        print("点击了第\(didClickImageAtIndex)张图片")
    }
}