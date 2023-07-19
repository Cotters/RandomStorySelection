import Foundation

extension Array {
  func takePercent(_ percent: Double) -> Self.SubSequence {
    let suffixAmount = Int(Double(self.count) * percent)
    return self.suffix(suffixAmount)
  }
}

class Story: Comparable {
  let id: Int
  let content: String
  var weight: Double = 1
  
  init(id: Int, content: String) {
    self.id = id
    self.content = content
  }
  
  func incrementWeight() {
    weight += 1
  }
  
  static func < (lhs: Story, rhs: Story) -> Bool {
    lhs.weight < rhs.weight
  }
  
  static func == (lhs: Story, rhs: Story) -> Bool {
    lhs.id == rhs.id
  }
}

let numOfStories = 20
let cutoffThreshold = 0.1

var stories = (1...numOfStories).map { Story(id: $0, content: "content for \($0)") }

var counter = newCounter()

func newCounter() -> [Int : Int] {
  (1...numOfStories).reduce(into: [:]) { (result, number) in
    result[number] = 0
  }
}

func sortedWeightedRandomSelection() -> Story {
  stories.sort(by: >)
  var selectedStory = stories.takePercent(cutoffThreshold).randomElement()!
  selectedStory.incrementWeight()
  
  return selectedStory
}

func weightedRandomSelection() -> Story {
  let avg = counter.values.reduce(0) { $0 + $1 } / numOfStories
  var numTimesChosen = counter.values.max()!
  var randomIndex = (0..<stories.count).randomElement()!
  while (numTimesChosen > (avg)) {
    if (numTimesChosen < counter.values.min() ?? .max) {
      break
    }
    let story = stories[randomIndex]
    numTimesChosen = counter[story.id] ?? 0
    randomIndex = (0..<stories.count).randomElement()!
  }
  return stories[randomIndex]
}

func randomSelection() -> Story {
  return stories.randomElement()!
}

let selectors = [sortedWeightedRandomSelection, randomSelection, weightedRandomSelection]

for selector in selectors {
  let startTime = DispatchTime.now()
  (0...1000).forEach { _ in
    counter[selector().id]! += 1
  }
  let endTime = DispatchTime.now()
  let nanoTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
  print("Elapsed time: \(nanoTime.inSeconds) seconds")
  
  print(counter.map(\.value))
  counter = newCounter()
}

extension UInt64 {
  var inSeconds: Double {
    return Double(self) / 1_000_000_000
  }
}
