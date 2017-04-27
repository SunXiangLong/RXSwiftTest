//
//  GoodsViewModel.swift
//  RXSwiftTest
//
//  Created by xiaomabao on 2017/4/27.
//  Copyright © 2017年 sunxianglong. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Moya
import SwiftyJSON
import Kingfisher
enum refreshStatus: Int {
    case dropDownSuccess // 下拉成功
    case pullSuccessHasMoreData // 上拉，还有更多数据
    case pullSuccessNoMoreData // 上拉，没有更多数据
    case invalidData // 无效的数据，请求失败或返回空数据等
}

extension UIImage{
    
    class func getImageWithColor(color:UIColor)->UIImage{
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
}

struct goods  {
    let goods_id:String?
    let goods_thumb:URL?
    let goods_name:String?
    let goods_price:String?
    init?(jsonData :JSON) {
        goods_id = jsonData["goods_id"].string
        goods_name = jsonData["goods_name"].string
        goods_price = jsonData["goods_price"].string
        goods_thumb = jsonData["goods_thumb"].url
    }
    static func ==(lhs: goods, rhs: goods) -> Bool {
        return lhs.goods_id == rhs.goods_id && lhs.goods_thumb == rhs.goods_thumb && lhs.goods_name == rhs.goods_name && lhs.goods_price == rhs.goods_price
    }
}

final class goodViewModel: ViewModelType {
    struct Input {
        let page:Driver<(String,String)>
        let selection: Driver<IndexPath>
    }
    struct Output {
        let posts: Driver<[goods]>
        let selectedPost: Driver<goods>
        let refreshStatus: Driver<refreshStatus>
    }
    private let navigator: PostsNavigator
    
    init(navigator: PostsNavigator) {
        
        self.navigator = navigator
    }
    func transform( input: goodViewModel.Input) -> goodViewModel.Output {
        
        
        let poods = input.page.flatMapLatest{[unowned self]  (requestTuples) in
            
            return self.data(page: requestTuples.0, goodCategaryID: requestTuples.1)
                
                .asDriver(onErrorJustReturn:[])
        }
        
        let selectedPost = input.selection
            .withLatestFrom(poods.scan([]){return $0+$1}) { (indexPath, posts) -> goods in
                print(posts.count)
                return posts[indexPath.row]
            }.do(onNext: navigator.toPost)
        
        let refreshStatus = Observable<refreshStatus>.create{ observable in
            
            poods
                .asObservable()
                
                .scan([goods]()){ arr1,arr2 in
                    
                    
                    if arr1.count > 0&&arr2.count > 0&&(arr1.first! == arr2.first!){
                        observable.onNext(.dropDownSuccess)
                        
                    }else{
                        
                        if arr2.count > 0{
                            observable.onNext(.pullSuccessHasMoreData)
                            
                        }else{
                            if arr1.count == 0 {
                                observable.onNext(.invalidData)
                            }else{
                                observable.onNext(.pullSuccessNoMoreData)
                            }
                            
                            
                        }
                        
                    }
                    
                    return arr1 + arr2
                }
                .subscribe(onNext: nil)
                .addDisposableTo(disposeBag)
            
            return Disposables.create()
            
        }
        
        
        
        return Output(posts:poods,selectedPost:selectedPost, refreshStatus: refreshStatus.asDriverOnErrorJustComplete())
    }
    
    func data(page:String,goodCategaryID:String) -> Observable<[goods]> {
        return XiaoMabaoProvider.request(.getCategoryGoods(id: goodCategaryID, page: page))
            .shareReplay(1)
            .filter{ event in
                if event.statusCode == 200{
                    return true;
                }
                return false
                
            }
            .mapJSON()
            .map{
                (JSON.init($0)["goods_list"].array!
                    .map{goods.init(jsonData: $0)!})
        }
        
        
        
    }
    
    deinit {
        print("\(String.init(describing: type(of: self))) ---> 被销毁 ")
    }
}
