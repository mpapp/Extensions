//
//  NSView+Extensions.swift
//  Extensions
//
//  Created by Matias Piipari on 12/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

extension NSView {
    
    public func addSubviewConstrainedToSuperViewEdges(aView:NSView,
                                                      topOffset:CGFloat = 0,
                                                      rightOffset:CGFloat = 0,
                                                      bottomOffset:CGFloat = 0,
                                                      leftOffset:CGFloat = 0) {
    
        aView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(aView)
        
        self.addEdgeConstraint(.Left, constantOffset: leftOffset, subview: aView)
        self.addEdgeConstraint(.Right, constantOffset: rightOffset, subview: aView)
        self.addEdgeConstraint(.Top, constantOffset: topOffset, subview: aView)
        self.addEdgeConstraint(.Bottom, constantOffset: bottomOffset, subview: aView)
    }
    
    public func addEdgeConstraint(edge:NSLayoutAttribute,
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