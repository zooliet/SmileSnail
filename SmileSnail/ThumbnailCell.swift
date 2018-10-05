//
//  ThumbnailCell.swift
//  SmileSnail
//
//  Created by hl1sqi on 05/10/2018.
//  Copyright © 2018 entlab. All rights reserved.
//

import UIKit

class ThumbnailCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbnailImage: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 3.0
        // layer.shadowRadius = 10
        // layer.shadowOpacity = 0.4
        // layer.shadowOffset = CGSize(width: 5, height: 10)
        self.clipsToBounds = false
    }
}
