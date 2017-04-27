//
//  GoodsCollectionViewCell.swift
//  RXSwiftTest
//
//  Created by xiaomabao on 2017/4/27.
//  Copyright © 2017年 sunxianglong. All rights reserved.
//

import UIKit

class goodsCollectionViewCell: UICollectionViewCell{
    
    
    @IBOutlet weak var goodimage: UIImageView!
    @IBOutlet weak var goodPrice: UILabel!
    @IBOutlet weak var goodName: UILabel!
    
    var model:goods?{
        didSet{
            goodimage.kf.setImage(with: model?.goods_thumb)
            goodPrice.text =  "￥" + (model?.goods_price!)!
            goodName.text = model!.goods_name
        }
    }
    deinit {
        print("\(String.init(describing: type(of: self))) ---> 被销毁 ")
    }
}
