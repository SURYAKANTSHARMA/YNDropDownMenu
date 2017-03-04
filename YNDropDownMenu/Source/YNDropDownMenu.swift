//
//  YNDropDownMenu.swift
//  YNDropDownMenu
//
//  Created by YiSeungyoun on 2017. 2. 18..
//  Copyright © 2017년 SeungyounYi. All rights reserved.
//

import UIKit

/// Main Class for YNDropDownMenu
open class YNDropDownMenu: UIView, YNDropDownDelegate {
    internal var opened: Bool = false
    internal var openedIndex: Int = 0
    
    internal var dropDownButtons: [YNDropDownButton]?
    internal var menuHeight: CGFloat = 0.0
    internal var numberOfMenu: Int = 0
    
    internal var buttonImages: YNImages?
    internal var buttonlabelFontColors: YNFontColor?
    internal var buttonlabelFonts: YNFont?
    
    internal var _dropDownViews: [UIView]?
    internal var dropDownViews: [UIView]? {
        get {
            return self._dropDownViews
        }
        set {
            guard let _dropDownViews = newValue else { return }
            for view in _dropDownViews {
                if let v = view as? YNDropDownView {
                    v.delegate = self
                }
            }
            self._dropDownViews = newValue
        }
    }
    
    internal var alwaysOnIndex: Int?
    internal var dropDownViewTitles: [String]?

    /// Blur effect view will changed if you change this popperty. Backgorund view don't have to be blur view (e.g. UIColor.black)
    open var blurEffectView: UIView? {
        didSet {
            self.changeBlurEffectView()
        }
    }
    /// Alpha Value if animation ended in *hideMenu()* function
    open var blurEffectViewAlpha:CGFloat = 1.0
    
    /// Blur effect style in background view
    open var blurEffectStyle:UIBlurEffectStyle = .dark
    
    /// Make background blur view enabled
    open var backgroundBlurEnabled = true
    
    /// Show menu second default value: *0.5*
    open var showMenuDuration = 0.5
    
    /// Hide menu second default value: *0.3*
    open var hideMenuDuration = 0.3
    
    /// Show menu spring velocity default value: *0.5*
    open var showMenuSpringVelocity:CGFloat = 0.5
    
    /// Show menu spring damping default value: *0.8*
    open var showMenuSpringWithDamping:CGFloat = 0.8
    
    /// Hide menu spring velocity Default value: *0.9*
    open var hideMenuSpringVelocity:CGFloat = 0.9
    
    /// Hide menu spring damping Default value: *0.8*
    open var hideMenuSpringWithDamping:CGFloat = 0.8
    
    
    /**
     Init YNDropDownMenu with frame, views, strings. Views count and titles count should be same
     
     - Parameter frame: CGRect Frame
     - Parameter dropDownViews: Use [UIView] or [YNDropDownView]
     - Parameter dropDownViewTitles: [String]
     */
    public init(frame: CGRect, dropDownViews: [UIView], dropDownViewTitles: [String]) {
        super.init(frame: frame)
        
        if dropDownViews.count != dropDownViewTitles.count {
            fatalError("Please make dropDownViews count same with dropDownViewsTitles count")
        } else {
            numberOfMenu = dropDownViews.count
        }
        
        self.dropDownViews = dropDownViews
        self.dropDownViewTitles = dropDownViewTitles
        self.menuHeight = self.frame.height
        
        self.initViews()
    }
    
    /// deprecated use init(frame: CGRect, dropDownViews: [UIView], dropDownViewTitles: [String]) instead
    @available(*, deprecated, message: "use init(frame: CGRect, dropDownViews: [UIView], dropDownViewTitles: [String]) instead")
    public init(frame: CGRect, YNDropDownViews: [YNDropDownView], dropDownViewTitles: [String]) {
        super.init(frame: frame)

        if YNDropDownViews.count != dropDownViewTitles.count {
            fatalError("Please make dropDownViews count same with dropDownViewsTitles count")
        } else {
            numberOfMenu = YNDropDownViews.count
        }

        self.dropDownViews = YNDropDownViews
        self.dropDownViewTitles = dropDownViewTitles
        self.menuHeight = self.frame.height

        self.initViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     Set arrow image or other images. Same image size is the best
     
     - Parameter normal: Normal image
     - Parameter selected: Selected image
     - Parameter disabled: Disabled image
     */
    open func setImageWhen(normal: UIImage?, selected: UIImage?, disabled: UIImage?) {
        self.buttonImages = YNImages.init(normal: normal, selected: selected, disabled: disabled)
        
        for i in 0..<numberOfMenu {
            dropDownButtons?[i].buttonImages = self.buttonImages
        }
    }
    
    /**
     Set label color.
     
     - Parameter normal: Normal color
     - Parameter selected: Selected color
     - Parameter disabled: Disabled color
     */
    open func setLabelColorWhen(normal: UIColor, selected: UIColor, disabled: UIColor) {
        self.buttonlabelFontColors = YNFontColor.init(normal: normal, selected: selected, disabled: disabled)
        
        for i in 0..<numberOfMenu {
            dropDownButtons?[i].labelFontColors = self.buttonlabelFontColors
        }
    }
    
    /**
     Set label font.
     
     - Parameter normal: Normal font
     - Parameter selected: Selected font
     - Parameter disabled: Disabled font
     */
    open func setLabelFontWhen(normal: UIFont, selected: UIFont, disabled: UIFont) {
        self.buttonlabelFonts = YNFont.init(normal: normal, selected: selected, disabled: disabled)
        
        for i in 0..<numberOfMenu {
            dropDownButtons?[i].labelFonts = self.buttonlabelFonts
        }
    }
    
    /**
     Make button label always selected. (not button image)
     
     - Parameter index: Index should be smaller than your menu counts
     */
    open func alwaysSelected(at index: Int) {
        self.checkIndex(index: index)
        self.alwaysOnIndex = index
        
        dropDownButtons?[index].buttonLabel.textColor = self.buttonlabelFontColors?.selected
        dropDownButtons?[index].buttonLabel.font = self.buttonlabelFonts?.selected
    }
    
    /**
     Make button disabled (title and image you set)
     
     - Parameter index: Index should be smaller than your menu counts
     */
    open func disabledMenu(at index: Int) {
        self.checkIndex(index: index)
        dropDownButtons?[index].disabled()
    }
    
    /**
     Makes button enabled (title and image you set)
     
     - Parameter index: Index should be smaller than your menu counts
     */
    open func enabledMenu(at index: Int) {
        self.checkIndex(index: index)
        dropDownButtons?[index].enabled()
    }
    
    /// Hide menu will be called when view is opened already.
    open func hideMenu() {
        if opened {
            hideMenu(yNDropDownButton: dropDownButtons?[openedIndex], buttonImageView: dropDownButtons?[openedIndex].buttonImageView, dropDownView: dropDownViews?[openedIndex], didComplete: nil)
            opened = !opened
        }
    }
    
    /**
     Change menu title you called. you can call it in YNDropDownMenu or YNDropDownView
     
     - Parameter index: Index should be smaller than your menu counts
     */
    open func changeMenu(title: String, at index: Int) {
        dropDownButtons?[index].buttonLabel.text = title

    }
    
    /**
     Change view you called. you can call it in YNDropDownMenu or YNDropDownView
     
     - Parameter index: Index should be smaller than your menu counts
     */
    open func changeView(view: UIView, at index: Int) {
        self.checkIndex(index: index)
        
        dropDownViews?[index] = view
        
        view.frame.size = CGSize(width: self.bounds.size.width, height: view.frame.size.height)
        view.frame.origin.y = -view.frame.height + CGFloat(menuHeight)
        view.isHidden = true

    }
    
    /**
     View will be closed and open when already opened. If not, just open drop down view
     
     - Parameter index: Index should be smaller than your menu counts
     */
    open func showAndHideMenu(at index: Int) {
        self.checkIndex(index: index)
        
        if openedIndex != index && opened {
            hideMenu(yNDropDownButton: dropDownButtons?[openedIndex], buttonImageView: dropDownButtons?[openedIndex].buttonImageView, dropDownView: dropDownViews?[openedIndex], didComplete: {
                self.showMenu(yNDropDownButton: self.dropDownButtons?[index], buttonImageView: self.dropDownButtons?[index].buttonImageView, dropDownView: self.dropDownViews?[index], didComplete: nil)
            })
            openedIndex = index
            return
        }
        openedIndex = index
        
        if !opened {
            showMenu(yNDropDownButton: dropDownButtons?[index], buttonImageView: dropDownButtons?[index].buttonImageView, dropDownView: dropDownViews?[index], didComplete: nil)
        } else {
            hideMenu(yNDropDownButton: dropDownButtons?[index], buttonImageView: dropDownButtons?[index].buttonImageView, dropDownView: dropDownViews?[index], didComplete: nil)

        }

        opened = !opened
    }
    
    @objc internal func menuClicked(_ sender: YNDropDownButton) {
        self.showAndHideMenu(at: sender.tag)
    }
    
    @objc internal func blurEffectViewClicked(_ sender: UITapGestureRecognizer) {
        self.hideMenu()
    }
    
    internal func checkIndex(index: Int) {
        if index >= numberOfMenu {
            fatalError("index should be smaller than menu count")
        }
    }
    
    internal func showMenu(yNDropDownButton: YNDropDownButton?, buttonImageView: UIImageView?, dropDownView: UIView?, didComplete: (()-> Void)?) {
        guard let yNDropDownButton = yNDropDownButton else { return }
        guard let dropDownView = dropDownView else { return }
        
        dropDownView.isHidden = false

        self.addSubview(dropDownView)
        self.sendSubview(toBack: dropDownView)
        
        if let v = dropDownView as? YNDropDownView {
            v.dropDownViewOpened()
        }
        
        if self.backgroundBlurEnabled, let _blurEffectView = blurEffectView {
            self.superview?.addSubview(_blurEffectView)
            self.superview?.insertSubview(_blurEffectView, belowSubview: self)
        }
        UIView.animate(
            withDuration: self.showMenuDuration,
            delay: 0,
            usingSpringWithDamping: self.showMenuSpringWithDamping,
            initialSpringVelocity: self.showMenuSpringVelocity,
            options: [],
            animations: {
                dropDownView.frame.origin.y = CGFloat(self.menuHeight)
                if self.backgroundBlurEnabled {
                    self.blurEffectView?.alpha = self.blurEffectViewAlpha
                }
                self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.width, height: dropDownView.frame.height + CGFloat(self.menuHeight))
                if let _buttonImageView = buttonImageView {
                    _buttonImageView.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI), 1.0, 0.0, 0.0)
                    _buttonImageView.image = self.buttonImages?.selected
                }
                yNDropDownButton.buttonLabel.textColor = self.buttonlabelFontColors?.selected
                yNDropDownButton.buttonLabel.font = self.buttonlabelFonts?.selected
                
        }, completion: { (completion) in
            guard let block = didComplete else { return }
            block()
        })
    }
    
    internal func hideMenu(yNDropDownButton: YNDropDownButton?, buttonImageView: UIImageView?, dropDownView: UIView?, didComplete: (()-> Void)?) {
        guard let yNDropDownButton = yNDropDownButton else { return }
        guard let dropDownView = dropDownView else { return }
        
        if let v = dropDownView as? YNDropDownView {
            v.dropDownViewClosed()
        }

        UIView.animate(
            withDuration: self.hideMenuDuration,
            delay: 0,
            usingSpringWithDamping: self.hideMenuSpringWithDamping,
            initialSpringVelocity: self.hideMenuSpringVelocity,
            options: [],
            animations: {
                dropDownView.frame.origin.y = CGFloat(self.menuHeight)
                if self.backgroundBlurEnabled {
                    self.blurEffectView?.alpha = 0
                }
                self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.width, height: CGFloat(self.menuHeight))
                if let _buttonImageView = buttonImageView {
                    _buttonImageView.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI), 0.0, 0.0, 0.0);
                    _buttonImageView.image = self.buttonImages?.normal
                }
                if self.alwaysOnIndex != yNDropDownButton.tag {
                    yNDropDownButton.buttonLabel.textColor = self.buttonlabelFontColors?.normal
                    yNDropDownButton.buttonLabel.font = self.buttonlabelFonts?.normal
                }

        }, completion: { (completion) in
            if self.backgroundBlurEnabled {
                self.blurEffectView?.removeFromSuperview()
                dropDownView.isHidden = true
            }
            guard let block = didComplete else { return }
            block()
        })
    }
    
    
    internal func changeBlurEffectView() {
        self.blurEffectView?.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.width, height: UIScreen.main.bounds.size.height - self.frame.origin.y)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(blurEffectViewClicked(_:)))
        self.blurEffectView?.addGestureRecognizer(tapGesture)
        self.blurEffectView?.alpha = 0

    }
    
    internal func initViews() {
        self.clipsToBounds = true
        
        self.backgroundColor = UIColor.white
        self.dropDownButtons = [YNDropDownButton]()
        
        let eachWidth = self.bounds.size.width / CGFloat(numberOfMenu)
        
        for i in 0..<numberOfMenu {
            // Setup button
            let button = YNDropDownButton(frame: CGRect(x: eachWidth * CGFloat(i), y: 0.0, width: eachWidth, height: CGFloat(menuHeight)), buttonLabelText: dropDownViewTitles?[i])
            button.tag = i
            button.addTarget(self, action: #selector(menuClicked(_:)), for: .touchUpInside)
            dropDownButtons?.append(button)
            
            self.addSubview(button)
            
            // Setup Views
            if let _dropDownView = dropDownViews?[i] {
                _dropDownView.frame.size = CGSize(width: self.bounds.size.width, height: _dropDownView.frame.height)
                _dropDownView.frame.origin.y = -_dropDownView.frame.height + CGFloat(menuHeight)
            }
        }
        
        let blurEffect = UIBlurEffect(style: blurEffectStyle)
        self.blurEffectView = UIVisualEffectView(effect: blurEffect)
        self.blurEffectView?.alpha = 0
        
        self.blurEffectView?.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.width, height: UIScreen.main.bounds.size.height - self.frame.origin.y)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(blurEffectViewClicked(_:)))
        self.blurEffectView?.addGestureRecognizer(tapGesture)
    }
}
