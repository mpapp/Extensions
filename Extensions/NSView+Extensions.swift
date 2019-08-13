//
//  NSView+Extensions.swift
//  Extensions
//
//  Created by Matias Piipari on 12/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//
//  ---------------------------------------------------------------------------
//
//  © 2019 Atypon Systems LLC
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

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
    
    public func mp_addEdgeConstraint(_ edge:NSLayoutConstraint.Attribute,
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
