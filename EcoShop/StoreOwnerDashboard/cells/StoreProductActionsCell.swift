//
//  StoreProductActionsCell.swift
//  EcoShop
//
//  Created by user244986 on 12/3/24.
//

import UIKit

protocol StoreProductActionsDelegate: AnyObject {
    func onSearch(sender: UITextField)
}

class StoreProductActionsCell: UITableViewCell {
    weak var delegate: StoreProductActionsDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
 
    @IBAction func editingChanged(_ sender: UITextField) {
        delegate?.onSearch(sender: sender)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
