import UIKit
import DateToolsSwift
import Neon

protocol EventViewDelegate: class {
  func eventViewDidTap(_ eventView: EventView)
  func eventViewDidLongPress(_ eventview: EventView)
}

//public protocol EventDescriptor: class {
//  var datePeriod: TimePeriod {get}
//  var text: String {get}
//  var attributedText: NSAttributedString? {get}
//  var font : UIFont {get}
//  var color: UIColor {get}
//  var textColor: UIColor {get}
//  var backgroundColor: UIColor {get}
//  var frame: CGRect {get set}
//  var status: String{get}
//  var billed: Bool{get}
//  var eventType: String {get}
//}

open class EventView: UIView {

  weak var delegate: EventViewDelegate?
  public var descriptor: EventDescriptor?
  private var fConsultation = false
  public var color = UIColor.lightGray

  var contentHeight: CGFloat {
    return textView.height
  }

  lazy var textView: UITextView = {
    let view = UITextView()
    view.isUserInteractionEnabled = false
    view.backgroundColor = .clear
    view.isScrollEnabled = false
    return view
  }()
  lazy var imageView : UIImageView = {
        var imageView = UIImageView.init();
        return imageView;
    }()
  lazy var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
  lazy var longPressGestureRecognizer: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress))

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }

  func configure() {
    clipsToBounds = true
    [tapGestureRecognizer, longPressGestureRecognizer].forEach {addGestureRecognizer($0)}

    color = tintColor
    addSubview(textView)
    addSubview(imageView)
    
    }

  func updateWithDescriptor(event: EventDescriptor) {
    if let attributedText = event.attributedText {
      textView.attributedText = attributedText
    } else {
      textView.text = event.text
      textView.textColor = event.textColor
      textView.font = event.font
    }
//    if(event.status.elementsEqual("confirmed")){
//        var image = UIImage.init(named: "c6")!;
//        imageView.image = image
//    }else if(event.status.elementsEqual("arrived") && !event.billed){
//        var image = UIImage.init(named: "c22")!;
//        imageView.image = image
//    }else if(event.billed){
//        var image = UIImage.init(named: "moneysign")!;
//        imageView.image = image
//
//    }else{
//        imageView.image = nil
//    }
    
    if(event.eventType.elementsEqual("fconsultation")){
        fConsultation = true
        var image = UIImage.init(named: "btn_primeraVez")!;
        imageView.image = image
    }else if(event.eventType.elementsEqual("consultation")){
        fConsultation = false
        var image = UIImage.init(named: "btn_Sub")!;
        imageView.image = image
    }else if(event.eventType.elementsEqual("surgery")){
        fConsultation = false
        var image = UIImage.init(named: "btn_Circ")!;
        imageView.image = image
    }else if(event.eventType.elementsEqual("personal")){
        fConsultation = false
//        var image = UIImage.init(named: "btn_Persc")!;
//        imageView.image = image
        imageView.image = nil
    }
    else if(event.eventType.elementsEqual("vacation")){
        fConsultation = false
//        var image = UIImage.init(named: "btn_Vacc")!;
//        imageView.image = image
        imageView.image = nil
    }
    else if(event.eventType.elementsEqual("congress")){
        fConsultation = false
//        var image = UIImage.init(named: "btn_Conc")!;
//        imageView.image = image
        imageView.image = nil
    }else{
        imageView.image = nil
        fConsultation = false
    }
    
    descriptor = event
    backgroundColor = event.backgroundColor
    color = event.color
    setNeedsDisplay()
    setNeedsLayout()
  }

    @objc func tap() {
    delegate?.eventViewDidTap(self)
  }

    @objc func longPress() {
    delegate?.eventViewDidLongPress(self)
  }

  override open func draw(_ rect: CGRect) {
    super.draw(rect)
    let context = UIGraphicsGetCurrentContext()
    context!.interpolationQuality = .none
    context?.saveGState()
    context?.setStrokeColor(color.cgColor)
    context?.setLineWidth(3)
    context?.translateBy(x: 0, y: 0.5)
    let x: CGFloat = 0
    let y: CGFloat = 0
    context?.beginPath()
    context?.move(to: CGPoint(x: x, y: y))
    context?.addLine(to: CGPoint(x: x, y: (bounds).height))
    
    context?.addLine(to: CGPoint(x: x , y: (bounds).height - 1))
    context?.addLine(to: CGPoint(x: x + rect.size.width, y: (bounds).height - 1 ))
    context?.strokePath()
    context?.restoreGState()
  }

  override open func layoutSubviews() {
    super.layoutSubviews()
    textView.fillSuperview(left: 0, right: 5, top: 0, bottom: 0)
    if(fConsultation){
        imageView.anchorInCorner(.topRight, xPad: 0, yPad: 0, width: 22, height: 22)
    }else{
        imageView.anchorInCorner(.topRight, xPad: 0, yPad: 0, width: 20, height: 20)
    }
  }
}
