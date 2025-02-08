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
    var imgFull: String
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
                title: "The Playground",
                content: tokenizeStr("Sunday afternoon, vacant playground.\n \nThe playground has <h>a slide</h>, <h>2 swing sets</h>, <h>a seasaw</h>, and <h>a bench</h>.\n \nFeel the warmth of the afternoon sun."),
                hint: nil,
                //                hint: tokenizeStr("Describe the vacancy. It is 7am, the playground is vacant.\n \nDescribe the set. You see <h>2 swing sets</h>, <h>a large slide</h>, <h>a set of monkey bars</h>, <h>a seesaw</h>, and <h>2 benches</h>\n \nDescribe the problem #1. You moved the swing, it <h>creaked</h>, as if it was <h>not maintained</h> for quite some time.\n \nDescribe the problem #2. You also notice the <h>ground was covered in leaves</h>."),
                img: "Presentation Image - Playground Observations Playground"
            ),
            PresentationPart(
                id: "2",
                title: "The Ground",
                content: tokenizeStr("Rubber ground, with a musky smell.\n \nGround <h>covered in leaves</h>, with the <h>scent of leaves</h>."),
                hint: nil,
                img: "Presentation Image - Playground Observations Leaves"
            ),
            PresentationPart(
                id: "3",
                title: "Chatter",
                content: tokenizeStr("An <h>elderly couple</h> came by and sat on the bench.\n \nYou <h>hear their chatter</h>, what seems to be gossip."),
                hint: nil,
                img: "Presentation Image - Playground Observations Chatting"
            ),
            PresentationPart(
                id: "4",
                title: "Children sliding in",
                content: tokenizeStr("Children and their guardians treacle in.\n \nChildren seen <h>sliding down the slide</h> creating a <h>screaching sound</h>.\n \nGuardians playing and monitoring their children."),
                hint: nil,
                img: "Presentation Image - Playground Observations Slide"
            ),
            PresentationPart(
                id: "5",
                title: "Swings",
                content: tokenizeStr("You hear the <h>swooshing of the swings</h>, seeing a child on it, swinging away.\n \nThere is an audible <h>creaking</h> coming from the swings."),
                hint: nil,
                img: "Presentation Image - Playground Observations Creaking Swing"
            ),
            PresentationPart(
                id: "6",
                title: "Chasing",
                content: tokenizeStr("Children running past you, next to the seasaw.\n \nYou hear them yelling and laughing."),
                hint: nil,
                img: "Presentation Image - Playground Observations Chasing"
            ),
            PresentationPart(
                id: "7",
                title: "Farewell",
                content: tokenizeStr("It is getting dark. You <h>hear people calling names</h>.\n \nYou hear children bidding their farewells.\n \nChildren held their guardians' hand as they went off."),
                hint: nil,
                img: "Presentation Image - Playground Observations Going Home"
            ),
        ],
        context: tokenizeStr("You went to your local playground to learn how residents living in the area are using it.\n \nYou will share what you <h>see</h>, <h>hear</h>, <h>smell</h>, and <h>feel</h>"),
        imgFull: "Display Image - Playground Observations Full",
        imgCompact: "Display Image - Playground Observations Compact",
        imgRegular: "Display Image - Playground Observations Regular"
    )
    
    static let ArtOfCommunicationPresentation: Presentation = Presentation(
        id: "Art of Communication",
        title: "Art of Communication",
        parts: [
            PresentationPart(
                id: "1",
                title: "The need to communicate",
                content: tokenizeStr("Communication is how we <h>get our ideas across</h> to our <h>audience</h>.\n \nIt comes in when we <h>talk to people</h>, <h>present</h>, and <h>design</h>."),
                hint: nil,
                img: "Presentation Image - Art of Communication Need for Communication"
            ),
            PresentationPart(
                id: "2",
                title: "Think about the audience",
                content: tokenizeStr("Firstly, understand who your <h>audience</h> is.\n \nFind out what sort of people they are, their general interests, and passion.\n \nThis orients what you plan to <h>communicate</h> and how you <h>frame</h> things."),
                hint: nil,
                img: "Presentation Image - Art of Communication The Audience"
            ),
            PresentationPart(
                id: "3",
                title: "Reorganise",
                content: tokenizeStr("You may have lots of things to say.\n \nIdentify and <h>group your thoughts</h>.\n \nReorganise these ideas to tell a <h>story</h>."),
                hint: nil,
                img: "Presentation Image - Art of Communication Reorganise"
            ),
            PresentationPart(
                id: "4",
                title: "Simplify",
                content: tokenizeStr("<h>Simplify</h>, complexity confuses the audience.\n \nLeave out the details until asked.\n \nYour goal is to <h>communicate not to impress</h>."),
                hint: nil,
                img: "Presentation Image - Art of Communication Simplify"
            ),
            PresentationPart(
                id: "5",
                title: "Associate with the Audience",
                content: tokenizeStr("<h>Reframe your ideas</h> to something your audience can <h>associate to</h>.\n \nUse <h>analogies</h>, and mediums like <h>images</h> and <h>videos</h> to get create associations."),
                hint: nil,
                img: "Presentation Image - Art of Communication Associate"
            ),
            PresentationPart(
                id: "6",
                title: "Listen",
                content: tokenizeStr("Communication is also about listening.\n \n<h>Paraphrase what you heard</h> and <h>reflect it back</h>.\n \nThis gives a chance for the speaker to gauge understanding."),
                hint: nil,
                img: "Presentation Image - Art of Communication Listen"
            ),
            PresentationPart(
                id: "7",
                title: "Good communication is about...",
                content: tokenizeStr("Good communication makes your audience <h>feel smart when they understand</h>, and <h>feel appreciated when heard</h>."),
                hint: nil,
                img: "Presentation Image - Art of Communication Good Communication"
            ),
            PresentationPart(
                id: "8",
                title: "Keep Practicing",
                content: tokenizeStr("Like any skill, getting good at communicating <h>requires practice</h>.\n \nLeverage on opportunities to <h>talk to people</h> and <h>use tools</h> like Presently to practice communication.\n \nSo <h>keep practicing</h>."),
                hint: nil,
                img: "Presentation Image - Art of Communication Practice"
            ),
        ],
        context: tokenizeStr("You will share what constitutes good communication."),
        imgFull: "Display Image - Art of Communication Full",
        imgCompact: "Display Image - Art of Communication Compact",
        imgRegular: "Display Image - Art of Communication Regular"
    )
    
}

