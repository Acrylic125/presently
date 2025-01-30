public struct PresentationPart {
    let id: String
    let title: String
    let content: [StringToken]
    let hint: [StringToken]?
    let img: String
}

public struct Presentation {
    var id: String
    var title: String
    var parts: [PresentationPart]
    var context: [StringToken]
    var imgCompact: String
    var imgRegular: String
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
        id: "Playground Observations",
        title: "Playground Observations",
        parts: [
            PresentationPart(
                id: "1",
                title: "First Look",
                content: tokenizeStr("7am, vacant playground.\n \nObserved 2 swing sets, and a large slide.\n \nProblem #1, Creaking swings\n \nProblem #2, Ground covered in leaves."),
                hint: tokenizeStr("Describe the vacancy. It is 7am, the playground is vacant.\n \nDescribe the set. You see <h>2 swing sets</h>, <h>a large slide</h>, <h>a set of monkey bars</h>, <h>a seesaw</h>, and <h>2 benches</h>\n \nDescribe the problem #1. You moved the swing, it <h>creaked</h>, as if it was <h>not maintained</h> for quite some time.\n \nDescribe the problem #2. You also notice the <h>ground was covered in leaves</h>."),
                img: "pimg_full_playground_observations"
            ),
            PresentationPart(
                id: "2",
                title: "Creaking Swimg Problem",
                content: tokenizeStr("Point <h>2</h> lol\n \n LOOOOL \n \nehdhhw whdhjwjkedw"),
                hint: nil,
                img: "pimg_full_playground_observations"
            ),
            PresentationPart(
                id: "3",
                title: "Leaves Problem",
                content: tokenizeStr("Point 3"),
                hint: nil,
                img: "pimg_full_playground_observations"
            ),
        ],
        context: tokenizeStr("You are a <h>town council representative</h> working to improve facilities in your neighbourhood.\n \nYou visited a local playground to observe how people <h>use the space</h> and <h>identify opportunities</h> for improvement.\n \nYou will present your <h>findings and recommendations</h>."),
        imgCompact: "pimg_partial_playground_observations",
        imgRegular: "pimg_partial_playground_observations_regular"
    )
    
}

