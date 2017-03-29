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

func characterViewRange(_ range:CountableClosedRange<UInt>, string:String) -> Range<String.CharacterView.Index> {
    
    return string.characters.index(string.characters.startIndex,
                                   offsetBy: Int(range.lowerBound))
           ..<
           string.characters.index(string.characters.startIndex,
                                   offsetBy: Int(range.upperBound))
}
