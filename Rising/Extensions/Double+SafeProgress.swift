import Foundation

extension Double {
    /// Returns a safe progress value between 0 and 1, handling NaN and infinities.
    /// Used to prevent invisible UI elements when division results in NaN.
    var safeProgress: Double {
        guard self.isFinite && self >= 0 else { return 0 }
        return min(self, 1.0)
    }
    
    /// Returns 0 if the receiver is NaN or infinite, otherwise returns self.
    var safeValue: Double {
        guard self.isFinite else { return 0 }
        return self
    }
}

extension Int {
    /// Safe division that returns 0 if divisor is 0.
    static func safeDivide(_ numerator: Double, by denominator: Double) -> Double {
        guard denominator != 0 else { return 0 }
        return numerator / denominator
    }
    
    static func safeDivide(_ numerator: Int, by denominator: Int) -> Int {
        guard denominator != 0 else { return 0 }
        return numerator / denominator
    }
}
