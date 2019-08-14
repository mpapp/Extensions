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

/*
extension CountableRange {
    public func overlaps(_ range:CountableRange<Element>) -> Bool {
        return self.contains(range.lowerBound) || self.contains(range.upperBound) || range.contains(self.lowerBound) || range.contains(self.upperBound)
    }
}

extension CountableClosedRange {
    public func overlaps(_ range:CountableClosedRange<Element>) -> Bool {
        return self.contains(range.lowerBound) || self.contains(range.upperBound) || range.contains(self.lowerBound) || range.contains(self.upperBound)
    }
}
 */

func characterViewRange(_ range:CountableClosedRange<UInt>, string:String) -> Range<String.Index> {
    
    return string.index(string.startIndex,
                        offsetBy: Int(range.lowerBound))
           ..<
           string.index(string.startIndex,
                        offsetBy: Int(range.upperBound))
}
