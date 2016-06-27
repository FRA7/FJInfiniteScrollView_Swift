//
//  FJInfiniteScrollView.swift
//  FJInfiniteScroll_Swift
//
//  Created by JYH on 16/6/25.
//  Copyright © 2016年 JYH. All rights reserved.
//

import UIKit

//MARK: - 定义一个枚举
public enum FJInfiniteScrollDirection {
    /** 左右滑动 */
    case FJInfiniteScrollDirectionHorizontal
    /** 上下滑动 */
    case FJInfiniteScrollDirectionVertical
}

//MARK: - 定义协议
protocol FJInfiniteScrollViewDelegate {
    //代理方法
    func infiniteScrollView(infiniteScrollView:FJInfiniteScrollView,didClickImageAtIndex:Int)
}



/** scrollView中imageView的数量 */
let ImageViewCount = 3

public class FJInfiniteScrollView: UIView {


    //MARK: - 属性
    /** 代理 */
    var delegate:FJInfiniteScrollViewDelegate?
    /** 每张图片之间的时间间隔 */
    public var interval:NSTimeInterval = 2{
        didSet{
            self.startTimer()
        }
    }

    /** 滚动方向 */
    public var scrollDirection:FJInfiniteScrollDirection = .FJInfiniteScrollDirectionHorizontal
    /** 图片数据(里面可以存放UIImage对象、NSString对象、NSURL对象【远程图片的URL】) */
    public var images = []{
        didSet{
            pageControl.numberOfPages = images.count
        }
    }
    /** 用于定时操作 */
    var time :NSTimer = NSTimer()
    /** 定义scrollView */
    let scrollView : UIScrollView = {
        var view = UIScrollView()
        view.pagingEnabled = true
        view.bounces = false
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    /** 页脚 */
    let pageControl : UIPageControl = UIPageControl()
    
    //MARK: - 生命周期
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //初始化子视图
        initChildView()
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        //布局子视图
        setLayoutSubview()
        //更新内容
        updateContentAndOffset()
    }
    
}

extension FJInfiniteScrollView{
    /**
     *  初始化子视图
     */
    private func initChildView(){
    
        //默认2秒轮播一次
        interval = 2
        //设置代理
        scrollView.delegate = self
        //不允许用户交互
        pageControl.userInteractionEnabled = false
        //添加到视图上面
        self.addSubview(scrollView)
        self.addSubview(pageControl)
        
        //创建imageView并添加手势
        for _ in 0...ImageViewCount {
            let imageView = UIImageView()
            imageView.userInteractionEnabled = true
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FJInfiniteScrollView.imageClick)))
            scrollView.addSubview(imageView)
        }
        
    }
    
    /**
     *  布局子视图
     */
    private func setLayoutSubview() {
        //拿到frame
        let selfW = self.frame.size.width
        let selfH = self.frame.size.height
        
        //设置他们的frame
        scrollView.frame = self.bounds
        if scrollDirection == .FJInfiniteScrollDirectionHorizontal{
            scrollView.contentSize = CGSizeMake(CGFloat(ImageViewCount) * selfW, 0)
        }else{
            scrollView.contentSize = CGSizeMake(0, CGFloat(ImageViewCount) * selfH)
        }
        
        for index in 0...ImageViewCount{
            let imageView = scrollView.subviews[index]
            if scrollDirection == .FJInfiniteScrollDirectionHorizontal {
                imageView.frame = CGRectMake(CGFloat(index) * selfW, 0, selfW, selfH)
            }else{
                imageView.frame = CGRectMake(0, CGFloat(index) * selfH, selfW, selfH)
            }
        }
        let pageControlW : CGFloat = 100
        let pageControlH : CGFloat = 25
        self.pageControl.frame = CGRectMake(selfW - pageControlW, selfH - pageControlH, pageControlW, pageControlH)
        
    }
    /**
     *  图片点击事件
     */
    @objc private func imageClick(tap:UITapGestureRecognizer){
        self.delegate?.infiniteScrollView(self, didClickImageAtIndex: (tap.view?.tag)!)
    }
    
    /**
     *  更新图片内容和scrollView 的偏移量
     */
    private func updateContentAndOffset(){
        
        let currentpage = self.pageControl.currentPage
        for i in 0..<ImageViewCount{
            let imageView = self.scrollView.subviews[i] as! UIImageView
            //根据当前页码求出imageIndex
            var imageIndex = 0
            if i == 0 {
                imageIndex = currentpage - 1
                if imageIndex == -1 {
                    imageIndex = images.count - 1
                }
            }
            else if i == 1{
                imageIndex = currentpage
            }else if i == 2{
                imageIndex = currentpage + 1
                if imageIndex == self.images.count{
                    imageIndex = 0
                }
            }
            imageView.tag = imageIndex
            
            
            //用来判断出来的值 为url 还是本地图片 还是image对象
            let obj = images[imageIndex]
            if obj.isKindOfClass(UIImage){
                imageView.image = obj as? UIImage
            }else if obj.isKindOfClass(NSString){
                imageView.image = UIImage(named: obj as! String)
            }else if obj.isKindOfClass(NSURL){
                imageView.sd_setImageWithURL(obj as! NSURL)
            }
        }
        if scrollDirection == .FJInfiniteScrollDirectionHorizontal {
            self.scrollView.contentOffset = CGPointMake(scrollView.frame.size.width, 0)
        }else{
            self.scrollView.contentOffset = CGPointMake(0, scrollView.frame.size.height)
        }
    }
}

//MARK: - 定时操作
extension FJInfiniteScrollView{
    
    
    private func startTimer(){
        
        time = NSTimer.scheduledTimerWithTimeInterval(self.interval, target: self, selector: #selector(nextPage), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(time, forMode: NSRunLoopCommonModes)
    }
    
    //停止定时器
    private func stopTimer(){
        time.invalidate()
        time = NSTimer()
    }
    
    /**
     下一页
     */
    @objc private func nextPage(){
        
        UIView.animateWithDuration(0.25, animations: { [weak self] in
            if self?.scrollDirection == .FJInfiniteScrollDirectionHorizontal{
                self?.scrollView.contentOffset = CGPointMake(2 * self!.scrollView.frame.size.width, 0)
            }else{
                self?.scrollView.contentOffset = CGPointMake(0, 2 * self!.scrollView.frame.size.height)
            }
            
            }) { [weak self] (_) -> Void in
                self?.updateContentAndOffset()
        }
    }
    
    
}

//MARK: - UIScrollViewDelegate
extension FJInfiniteScrollView:UIScrollViewDelegate{
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        //找出显示在最中间的imageView
        var middleImageView : UIImageView = UIImageView()
        //x值和偏移量x的最小差值
        var minDelta = MAXFLOAT
        
        for i in 0..<ImageViewCount {
            let imageView = scrollView.subviews[i]
            //x值和偏移量x差值最小的imageView,就是显示在最中间的imageView
            var currentDelta : CGFloat = 0
            if self.scrollDirection == .FJInfiniteScrollDirectionHorizontal {
                currentDelta = fabs(imageView.frame.origin.x - self.scrollView.contentOffset.x)
            }else{
                currentDelta = fabs(imageView.frame.origin.y - self.scrollView.contentOffset.y)
            }
            if currentDelta < CGFloat(minDelta) {
                minDelta = Float(minDelta)
                middleImageView = (imageView as? UIImageView)!
            }
        }
        self.pageControl.currentPage = middleImageView.tag
    }
    
    /**
     停止减速时执行
     */
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        updateContentAndOffset()
    }
    
    
    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.stopTimer()
    }
    
    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.startTimer()
    }
}












