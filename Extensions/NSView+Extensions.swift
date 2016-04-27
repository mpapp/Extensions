//
//  NSView+Extensions.swift
//  Extensions
//
//  Created by Matias Piipari on 12/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

extension NSView {
    
    public func mp_addSubviewConstrainedToSuperViewEdges(aView:NSView,
                                                      topOffset:CGFloat = 0,
                                                      rightOffset:CGFloat = 0,
                                                      bottomOffset:CGFloat = 0,
                                                      leftOffset:CGFloat = 0) {
    
        aView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(aView)
        
        self.mp_addEdgeConstraint(.Left, constantOffset: leftOffset, subview: aView)
        self.mp_addEdgeConstraint(.Right, constantOffset: rightOffset, subview: aView)
        self.mp_addEdgeConstraint(.Top, constantOffset: topOffset, subview: aView)
        self.mp_addEdgeConstraint(.Bottom, constantOffset: bottomOffset, subview: aView)
    }
    
    public func mp_addEdgeConstraint(edge:NSLayoutAttribute,
                                     constantOffset:CGFloat = 0,
                                     subview:NSView) -> NSLayoutConstraint {
        let constraint:NSLayoutConstraint
                = NSLayoutConstraint(item:subview,
                                     attribute:edge,
                                     relatedBy:.Equal,
                                     toItem:self,
                                     attribute:edge,
                                     multiplier:1,
                                     constant:constantOffset)
        
        self.addConstraint(constraint)

        return constraint;
    }
}