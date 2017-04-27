//
//  ViewController.swift
//  RXSwiftTest
//
//  Created by xiaomabao on 2017/4/21.
//  Copyright © 2017年 sunxianglong. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MJRefresh
import DGElasticPullToRefresh


class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var viewModel: goodViewModel!
    let loadingView = DGElasticPullToRefreshLoadingViewCircle()
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        bindViewModel()
        
    }
    func configureCollectionView(){
        let layout = UICollectionViewFlowLayout.init()
        layout.sectionInset = UIEdgeInsetsMake(3, 3, 3, 3);
        layout.minimumLineSpacing = 3
        layout.minimumInteritemSpacing = 3;
        
        layout.itemSize =  CGSize.init(width: (self.view.frame.size.width - 9)/2, height: (self.view.frame.size.width - 9)/2+70);
        collectionView.collectionViewLayout  = layout;
       
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.getImageWithColor(color: UIColor.white), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        
        
        
        
    }
    
    var page = 2;
    
    func bindViewModel() {
        
        /// 上拉加载更多和下拉刷新数据
        let myJust = Observable<(String,String)>.create {[unowned self]   observer in
            
            self.collectionView.mj_footer = MJRefreshAutoNormalFooter.init {
                
                observer.on(.next("\(self.page)","904"))
            
            }
            
            self.collectionView.dg_addPullToRefreshWithActionHandler({ () -> Void in
                self.page = 1;
                observer.on(.next("\(self.page)","904"))
                
            }, loadingView: self.loadingView)
            
            self.loadingView.tintColor = UIColor.gray
            self.collectionView.dg_setPullToRefreshFillColor(UIColor.white)
            self.collectionView.dg_setPullToRefreshBackgroundColor(self.collectionView.backgroundColor!)
            self.collectionView.mj_footer.isHidden = true
            print(self.collectionView.subviews)
            return Disposables.create()
        }
        
        viewModel = goodViewModel.init(navigator: DefaultPostsNavigator.init(navigationController: self.navigationController!, storyBoard: UIStoryboard.init(name: "Main", bundle: nil)));
        
        
        assert(viewModel != nil)
        
        
        let input = goodViewModel.Input.init(page: myJust.startWith(("1","904")).asDriverOnErrorJustComplete(), selection: collectionView.rx.itemSelected.asDriver())
        let output = viewModel.transform(input: input)
        
        /// 事件的订阅或绑定
        output
            .posts
            .scan([])
            {[unowned self]  arr1,arr2 in
                if self.page == 1{
                    
                    return  arr2
                }else{
                    return  arr1+arr2
                }
                
            }
            .filter{
                if ($0.count>0){
                    return true
                }else{
                    return false
                }
                
            }
            .drive(collectionView.rx.items(cellIdentifier: "goodsCollectionViewCell", cellType: goodsCollectionViewCell.self)){ tv, item, cell in
                cell.model = item
            }.addDisposableTo(disposeBag)
        
        output.selectedPost.drive().addDisposableTo(disposeBag)
        
        output.refreshStatus.drive(refreshStatusBinding).addDisposableTo(disposeBag)
    }
    
    /// 自定义的绑定事件
    var refreshStatusBinding: UIBindingObserver<ViewController, refreshStatus> {
        return UIBindingObserver(UIElement: self, binding: {[unowned self]   (vc, refreshStatus) in
            self.collectionView.mj_footer.isHidden = false
            self.collectionView.mj_footer.endRefreshing()
            self.collectionView.dg_stopLoading()
            
            switch refreshStatus {
            case .pullSuccessHasMoreData:
                self.page = self.page + 1
            case .pullSuccessNoMoreData:
                self.collectionView.mj_footer.endRefreshingWithNoMoreData()
            case .invalidData:
                self.collectionView.mj_footer.isHidden = true
            case.dropDownSuccess:
                self.page = self.page + 1
    
            }
        })
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit{
        print("\(String.init(describing: type(of: self))) ---> 被销毁 ")
        collectionView.dg_removePullToRefresh()
    }
    
    
    
    
}


