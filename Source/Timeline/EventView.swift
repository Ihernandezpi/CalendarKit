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
  private var notConfirmed = false
    private var videocall = false
  public var color = UIColor.lightGray
  public var stripesColors : [UIColor]?

  var contentHeight: CGFloat {
    return textView.height
  }

  lazy var textView: UITextView = {
    let view = UITextView()
    view.isUserInteractionEnabled = false
    view.backgroundColor = .clear
    view.isScrollEnabled = false
    view.textColor = .black
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
//  lazy var imageView : UIImageView = {
//        var imageView = UIImageView.init();
//    imageView.translatesAutoresizingMaskIntoConstraints = false
//        return imageView;
//    }()
    lazy var eventyTypeText : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 10)
        label.textAlignment = .right
        return label
    }()
    lazy var videoCallImage : UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "baseline_videocam_black_24pt"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = UIColor(red: 0.52, green: 0.40, blue: 0.92, alpha: 1.00)
        return imageView
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

    var widthVideoCall: NSLayoutConstraint!
    var marginLeftText: NSLayoutConstraint!
  func configure() {
    clipsToBounds = true
    [tapGestureRecognizer, longPressGestureRecognizer].forEach {addGestureRecognizer($0)}

    color = tintColor
    addSubview(textView)
    addSubview(eventyTypeText)
    addSubview(videoCallImage)
    
    self.videoCallImage.topAnchor.constraint(equalTo: self.topAnchor, constant: 4).isActive = true
    self.videoCallImage.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 4).isActive = true
    widthVideoCall = self.videoCallImage.widthAnchor.constraint(equalToConstant: 20)
    widthVideoCall.isActive = true
    self.videoCallImage.heightAnchor.constraint(equalToConstant: 20).isActive = true
    
    self.eventyTypeText.topAnchor.constraint(equalTo: self.topAnchor, constant: 4).isActive = true
    self.eventyTypeText.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -4).isActive = true
    self.eventyTypeText.widthAnchor.constraint(equalToConstant: 50).isActive = true
    self.eventyTypeText.heightAnchor.constraint(equalToConstant: 20).isActive = true
    
    self.textView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
    marginLeftText = self.textView.leftAnchor.constraint(equalTo: self.videoCallImage.rightAnchor, constant: 4)
    marginLeftText.isActive = true
    self.textView.rightAnchor.constraint(equalTo: self.eventyTypeText.leftAnchor, constant: 4).isActive = true
    self.textView.heightAnchor.constraint(equalToConstant: 30).isActive = true
    
    }

  func updateWithDescriptor(event: EventDescriptor) {
    if let attributedText = event.attributedText {
      textView.attributedText = attributedText
    } else {
      textView.text = event.text
      textView.textColor = event.textColor
      textView.font = event.font
    }
    if(event.eventType.elementsEqual("fconsultation")){
        fConsultation = true
//        var image = UIImage.init(named: "btn_primeraVez")!;
//        imageView.image = image
        eventyTypeText.text = "1ra. Vez"
    }else if(event.eventType.elementsEqual("consultation")){
        fConsultation = false
//        var image = UIImage.init(named: "btn_Sub")!;
//        imageView.image = image
        eventyTypeText.text = "Sub"
    }else if(event.eventType.elementsEqual("surgery")){
        fConsultation = false
//        var image = UIImage.init(named: "btn_Circ")!;
//        imageView.image = image
        eventyTypeText.text = "Cir"
    }else if(event.eventType.elementsEqual("recurrent")){
        fConsultation = false
//        var image = UIImage.init(named: "btn_Rec")!;
//        imageView.image = image
        eventyTypeText.text = "Evt. Rec"
    }else if(event.eventType.elementsEqual("personal")){
        fConsultation = false
        eventyTypeText.text = ""
    }
    else if(event.eventType.elementsEqual("vacation")){
        fConsultation = false
        eventyTypeText.text = ""
    }
    else if(event.eventType.elementsEqual("congress")){
        fConsultation = false
        eventyTypeText.text = ""
    }else{
        eventyTypeText.text = ""
        fConsultation = false
    }
    stripesColors = event.stripesColors
    color = event.color
    descriptor = event
    backgroundColor = event.backgroundColor
    notConfirmed = event.eventType.elementsEqual("notConfirmed")
    if (notConfirmed){
        color = stripesColors![1]
    }
    videocall = event.videocall
    if videocall {
        widthVideoCall.constant = 20
        marginLeftText.constant = 4
    }else{
        widthVideoCall.constant = 0
        marginLeftText.constant = 0
    }
    if event.status.elementsEqual("canceled"){
        if var title = textView.text{
            var newTitle = NSAttributedString(string: title, attributes: [.strikethroughStyle: 2, .font: UIFont.boldSystemFont(ofSize: 12), .foregroundColor: UIColor.white])
            textView.attributedText = newTitle
        }
    }else{
        
    }
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
    
    if notConfirmed {
       let stripeWidth: CGFloat = 20.0 // whatever you want
        let m = stripeWidth / 2.0

        guard let c = UIGraphicsGetCurrentContext() else { return }
        c.setLineWidth(stripeWidth)

        let r = CGRect(x: x, y: y, width: width, height: height)
        let longerSide = width > height ? width : height

        c.saveGState()
        c.clip(to: r)

            var p = x - longerSide
            while p <= x + width {

                c.setStrokeColor(stripesColors![0].cgColor)
                c.move( to: CGPoint(x: p-m, y: y-m) )
                c.addLine( to: CGPoint(x: p+m+height, y: y+m+height) )
                c.strokePath()

                p += stripeWidth

                c.setStrokeColor(stripesColors![1].cgColor)
                c.move( to: CGPoint(x: p-m, y: y-m) )
                c.addLine( to: CGPoint(x: p+m+height, y: y+m+height) )
                c.strokePath()

                p += stripeWidth
            }
    }
    
    
    context?.restoreGState()
  }

  override open func layoutSubviews() {
    super.layoutSubviews()

    
//    textView.fillSuperview(left: 0, right: 0, top: 0, bottom: 0)
//    if(fConsultation){
//        imageView.anchorInCorner(.topRight, xPad: 0, yPad: 0, width: 22, height: 22)
//    }else{
//        imageView.anchorInCorner(.topRight, xPad: 0, yPad: 0, width: 20, height: 20)
//    }
  }
}
