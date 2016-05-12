extension Range {
    public func overlaps(range:Range<Element>) -> Bool {
        return self.contains(range.startIndex) || self.contains(range.endIndex) || range.contains(self.startIndex) || range.contains(self.endIndex)
    }
}

func characterViewRange(range:Range<UInt>, string:String) -> Range<String.CharacterView.Index> {
    return string.characters.startIndex.advancedBy(Int(range.startIndex)) ..< string.characters.startIndex.advancedBy(Int(range.endIndex))
}