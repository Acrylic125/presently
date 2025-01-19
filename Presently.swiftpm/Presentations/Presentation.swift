public struct PresentationPart {
    let heading: String
    let pointers: [[StringToken]]
    let img: String
}

public struct Presentation {
    let parts: [PresentationPart]
    let context: [StringToken]
    let img: String
}

public enum StringTokenType {
    case highlight, normal
}

public struct StringToken {
    let text: String
    let type: StringTokenType
}

/**
 * Tokenizes a string for view rendering.
 *
 * Example: "Hello world, this is an <h>example</h> text."
 * -> To be rendered where ["Hello world, this is an ", "example", "text." ] such that "example" will be highlighted.
 */
public func tokenizeStr(_ input: String) -> [StringToken] {
    var tokens: [StringToken] = []
    var currentIndex = input.startIndex
    
    while currentIndex < input.endIndex {
        if let highlightStart = input[currentIndex...].range(of: "<h>") {
            if currentIndex < highlightStart.lowerBound {
                let normalText = String(input[currentIndex..<highlightStart.lowerBound])
                tokens.append(StringToken(text: normalText, type: .normal))
            }
            
            if let highlightEnd = input[highlightStart.upperBound...].range(of: "</h>") {
                let highlightedText = String(input[highlightStart.upperBound..<highlightEnd.lowerBound])
                tokens.append(StringToken(text: highlightedText, type: .highlight))
                currentIndex = highlightEnd.upperBound
            } else {
                let remainingText = String(input[currentIndex...])
                tokens.append(StringToken(text: remainingText, type: .normal))
                break
            }
        } else {
            let remainingText = String(input[currentIndex...])
            tokens.append(StringToken(text: remainingText, type: .normal))
            break
        }
    }
    
    return tokens
}

public struct AppPresentations {
    static let PlaygroundObservationsPresentation: Presentation = Presentation(
        parts: [
            PresentationPart(heading: "Part 1", pointers: [
                tokenizeStr("Point 1"),
                tokenizeStr("Point 2"),
                tokenizeStr("Point 3"),
                tokenizeStr("Point 4"),
                tokenizeStr("Point 5")
            ], img: "")
        ],
        context: tokenizeStr("You are a <h>town council representative</h> working to improve facilities in your\n \nYou visited a local playground to observe how people <h>use the space</h> and <h>identify opportunities</h> for improvement.\n \nYou will present your <h>findings and recommendations</h>."),
        img: ""
    )

}

