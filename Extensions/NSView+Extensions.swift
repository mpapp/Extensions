//
//  NSView+Extensions.swift
//  Extensions
//
//  Created by Matias Piipari on 12/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Cocoa

extension NSView {
    
    public func mp_addSubviewConstrainedToSuperViewEdges(_ aView:NSView,
                                                      topOffset:CGFloat = 0,
                                                      rightOffset:CGFloat = 0,
                                                      bottomOffset:CGFloat = 0,
                                                      leftOffset:CGFloat = 0) {
    
        aView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(aView)
        
        _ = self.mp_addEdgeConstraint(.left, constantOffset: leftOffset, subview: aView)
        _ = self.mp_addEdgeConstraint(.right, constantOffset: rightOffset, subview: aView)
        _ = self.mp_addEdgeConstraint(.top, constantOffset: topOffset, subview: aView)
        _ = self.mp_addEdgeConstraint(.bottom, constantOffset: bottomOffset, subview: aView)
    }
    
    public func mp_addEdgeConstraint(_ edge:NSLayoutAttribute,
                                     constantOffset:CGFloat = 0,
                                     subview:NSView) -> NSLayoutConstraint {
        let constraint:NSLayoutConstraint
                = NSLayoutConstraint(item:subview,
                                     attribute:edge,
                                     relatedBy:.equal,
                                     toItem:self,
                                     attribute:edge,
                                     multiplier:1,
                                     constant:constantOffset)
        
        self.addConstraint(constraint)

        return constraint;
    }
}
