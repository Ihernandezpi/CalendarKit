import UIKit
import Neon
import DateToolsSwift

extension Date {
    func convertToLocalTime(fromTimeZone timeZoneAbbreviation: String) -> Date? {
        if let timeZone = TimeZone(identifier : timeZoneAbbreviation) {
            let targetOffset = TimeInterval(timeZone.secondsFromGMT(for: self))
            let localOffeset = TimeInterval(TimeZone.autoupdatingCurrent.secondsFromGMT(for: self))
            
            return self.addingTimeInterval(targetOffset - localOffeset)
        }
        
        return nil
    }
}
protocol TimelineViewDelegate: class {
  
  func timelineView(_ timelineView: TimelineView, didLongPressAt hour: Int)
}

public class TimelineView: UIView, ReusableView {
    var dayBlockHours : [String] = [];
    
  weak var delegate: TimelineViewDelegate?

  weak var eventViewDelegate: EventViewDelegate?

  var date = Date() {
    didSet {
      setNeedsLayout()
    }
  }

  var currentTime: Date {
      return Date().convertToLocalTime(fromTimeZone: "America/Mexico_City")!
  }
    
  var eventViews = [EventView]()
//  var eventDescriptors = [EventDescriptor]() {
//    didSet {
//      recalculateEventLayout()
//      prepareEventViews()
//      setNeedsLayout()
//    }
//  }
    
    public var layoutAttributes = [EventLayoutAttributes]() {
        didSet {
            recalculateEventLayout()
            prepareEventViews()
            setNeedsLayout()
        }
    }
    
  var pool = ReusePool<EventView>()

  var firstEventYPosition: CGFloat? {
    return layoutAttributes.sorted{$0.frame.origin.y < $1.frame.origin.y}
      .first?.frame.origin.y
  }

  lazy var nowLine: CurrentTimeIndicator = CurrentTimeIndicator()

  var style = TimelineStyle()

  var verticalDiff: CGFloat = 70
  var verticalInset: CGFloat = 10
  var leftInset: CGFloat = 53

  var horizontalEventInset: CGFloat = 3

  var fullHeight: CGFloat {
    return verticalInset * 2 + verticalDiff * 24
  }

  var calendarWidth: CGFloat {
    return bounds.width - leftInset
  }
    
  var is24hClock = false {
    didSet {
      setNeedsDisplay()
    }
  }

  init() {
    super.init(frame: .zero)
    frame.size.height = fullHeight
    configure()
  }

  var times: [String] {
    return is24hClock ? _24hTimes : _12hTimes
  }

  fileprivate lazy var _12hTimes: [String] = Generator.timeStrings12H()
  fileprivate lazy var _24hTimes: [String] = Generator.timeStrings24H()
  
  fileprivate lazy var longPressGestureRecognizer: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))

  var isToday: Bool {
    return date.isToday
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }

  func configure() {
    contentScaleFactor = 1
    layer.contentsScale = 1
    contentMode = .redraw
    backgroundColor = .white
    addSubview(nowLine)
    
    // Add long press gesture recognizer
    addGestureRecognizer(longPressGestureRecognizer)
  }
  
    @objc func longPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
    if (gestureRecognizer.state == .began) {
      // Get timeslot of gesture location
      let pressedLocation = gestureRecognizer.location(in: self)
      let percentOfHeight = (pressedLocation.y - verticalInset) / (bounds.height - (verticalInset * 2))
      let pressedAtHour: Int = Int(24 * percentOfHeight)
      delegate?.timelineView(self, didLongPressAt: pressedAtHour)
    }
  }

  public func updateStyle(_ newStyle: TimelineStyle) {
    style = newStyle.copy() as! TimelineStyle
    nowLine.updateStyle(style.timeIndicator)
    backgroundColor = style.backgroundColor
    setNeedsDisplay()
  }

  override public func draw(_ rect: CGRect) {
    super.draw(rect)

    var hourToRemoveIndex = -1

    if isToday {
      let minute = currentTime.minute
      if minute > 39 {
        hourToRemoveIndex = currentTime.hour + 1
      } else if minute < 21 {
        hourToRemoveIndex = currentTime.hour
      }
    }

    let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
    paragraphStyle.lineBreakMode = .byWordWrapping
    paragraphStyle.alignment = .right

    let attributes : [NSAttributedString.Key : Any] = [NSAttributedString.Key.paragraphStyle: paragraphStyle,
                                                       NSAttributedString.Key.foregroundColor: self.style.timeColor,
                                                       NSAttributedString.Key.font: style.font]

    for (i, time) in times.enumerated() {
      let iFloat = CGFloat(i)
      let context = UIGraphicsGetCurrentContext()
      context!.interpolationQuality = .none
      context?.saveGState()
      context?.setStrokeColor(self.style.lineColor.cgColor)
      context?.setLineWidth(onePixel)
      context?.translateBy(x: 0, y: 0.5)
      let x: CGFloat = 53
      let y = verticalInset + iFloat * verticalDiff
      context?.beginPath()
      context?.move(to: CGPoint(x: x, y: y))
      context?.addLine(to: CGPoint(x: (bounds).width, y: y))
      context?.strokePath()
      context?.restoreGState()
        
        //Blocked hours background
        let formater : DateFormatter = DateFormatter()
        formater.dateFormat = "hh a"
        formater.amSymbol = "AM"
        formater.pmSymbol = "PM"
//        if let dateTime = formater.date(from: time){
            let dateString = String(format:"%d",i)
        print(dayBlockHours)
            for case dateString in dayBlockHours {
                context?.addRect(CGRect(x: x, y: y, width: (bounds).width, height: verticalDiff))
                context?.setFillColor(UIColor(red:0.50, green:0.58, blue:0.60, alpha:0.5).cgColor)
                context?.setLineWidth(1)
                context?.fillPath();
            }
//        }
        
      //if i == hourToRemoveIndex { continue }
        
      let fontSize = style.font.pointSize
      let timeRect = CGRect(x: 2, y: iFloat * verticalDiff + verticalInset - 7,
                            width: leftInset - 8, height: fontSize + 2)

      let timeString = NSString(string: time)

      timeString.draw(in: timeRect, withAttributes: attributes)
    }
  }

  override public func layoutSubviews() {
    super.layoutSubviews()
    recalculateEventLayout()
    layoutEvents()
    layoutNowLine()
  }

  func layoutNowLine() {
    if !isToday {
      nowLine.alpha = 0
    } else {
        bringSubviewToFront(nowLine)
      nowLine.alpha = 1
      let size = CGSize(width: bounds.size.width, height: 20)
      let rect = CGRect(origin: CGPoint.zero, size: size)
      nowLine.date = currentTime
      nowLine.frame = rect
      nowLine.center.y = dateToY(currentTime)
        nowLine.alpha = 0 /// Esta línea desaparece la hora actual... está bugueada mejor la quitamos 28 marzo 2023
    }
  }

  func layoutEvents() {
    if eventViews.isEmpty {return}

    for (idx, attributes) in layoutAttributes.enumerated() {
      let descriptor = attributes.descriptor
      let eventView = eventViews[idx]
      eventView.frame = attributes.frame
      eventView.updateWithDescriptor(event: descriptor)
    }
  }

  func recalculateEventLayout() {
    let sortedEvents = layoutAttributes.sorted { (attr1, attr2) -> Bool in
      let start1 = attr1.descriptor.startDate
      let start2 = attr2.descriptor.startDate
      return start1.isEarlier(than: start2)
    }

    var groupsOfEvents = [[EventLayoutAttributes]]()
    var overlappingEvents = [EventLayoutAttributes]()

    for event in sortedEvents {
      if overlappingEvents.isEmpty {
        overlappingEvents.append(event)
        continue
      }

      let longestEvent = overlappingEvents.sorted { (attr1, attr2) -> Bool in
        let period1 = attr1.descriptor.datePeriod.seconds
        let period2 = attr2.descriptor.datePeriod.seconds
        return period1 > period2
        }
        .first!

      let lastEvent = overlappingEvents.last!
      if longestEvent.descriptor.datePeriod.overlaps(with: event.descriptor.datePeriod) ||
        lastEvent.descriptor.datePeriod.overlaps(with: event.descriptor.datePeriod) {
        overlappingEvents.append(event)
        continue
      } else {
        groupsOfEvents.append(overlappingEvents)
        overlappingEvents.removeAll()
        overlappingEvents.append(event)
      }
    }

    groupsOfEvents.append(overlappingEvents)
    overlappingEvents.removeAll()

    for overlappingEvents in groupsOfEvents {
      let totalCount = CGFloat(overlappingEvents.count)
      for (index, event) in overlappingEvents.enumerated() {
        let startY = dateToY(event.descriptor.datePeriod.beginning!)
        let endY = dateToY(event.descriptor.datePeriod.end!)
        let floatIndex = CGFloat(index)
        let x = leftInset + floatIndex / totalCount * calendarWidth
        let equalWidth = calendarWidth / totalCount
        var height = endY - startY;
        if(height < 20){
            height = 20;
        }
        event.frame = CGRect(x: x, y: startY, width: equalWidth, height: height)
      }
    }
  }

  func prepareEventViews() {
    pool.enqueue(views: eventViews)
    eventViews.removeAll()
    for _ in 0...layoutAttributes.endIndex {
      let newView = pool.dequeue()
      newView.delegate = eventViewDelegate
      if newView.superview == nil {
        addSubview(newView)
      }
      eventViews.append(newView)
    }
  }

  func prepareForReuse() {
    pool.enqueue(views: eventViews)
    eventViews.removeAll()
    setNeedsDisplay()
  }

  // MARK: - Helpers

  fileprivate var onePixel: CGFloat {
    return 1 / UIScreen.main.scale
  }

  fileprivate func dateToY(_ date: Date) -> CGFloat {
    if date.dateOnly() > self.date.dateOnly() {
      // Event ending the next day
      return 24 * verticalDiff + verticalInset
    } else if date.dateOnly() < self.date.dateOnly() {
      // Event starting the previous day
      return verticalInset
    } else {
      let hourY = CGFloat(date.hour) * verticalDiff + verticalInset
      let minuteY = CGFloat(date.minute) * verticalDiff / 60
      return hourY + minuteY
    }
  }
  
}
