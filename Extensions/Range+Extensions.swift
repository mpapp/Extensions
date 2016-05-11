extension Range {
    
    public func overlaps(range:Range<Element>) -> Bool {
        return self.contains(range.startIndex) || self.contains(range.endIndex) || range.contains(self.startIndex) || range.contains(self.endIndex)
    }

}

/*
infix operator … {}
public func …<T:ForwardIndexType>(left:T, right:T) -> Range<T> {
    return left ... right
}*/