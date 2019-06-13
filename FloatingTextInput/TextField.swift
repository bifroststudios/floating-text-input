//
//  TextField.swift
//  FloatingTextInput
//
//  Created by Alexander Ignatev on 23/10/2018.
//  Copyright © 2018 Redmadrobot OOO. All rights reserved.
//

import UIKit

open class TextField: UITextField {

    /// Контейнер с дополнительными лейблами.
    internal let textBox = TextBox()

    private var rightViews = [TextInputState: UIView]()

    /// Заголовок.
    @IBInspectable open var title: String? {
        get { return textBox.title }
        set { textBox.title = newValue }
    }

    /// Шрифт заголовка.
    open var titleFont: UIFont? {
        get { return textBox.titleLabel.font }
        set { textBox.titleLabel.font = newValue }
    }

    /// Цвет текста заголовка.
    @IBInspectable open var titleColor: UIColor? {
        get { return textBox.titleColor }
        set { textBox.titleColor = newValue }
    }

    open var placeholderFont: UIFont? {
        get { return textBox.placeholderFont }
        set { textBox.placeholderFont = newValue }
    }

    /// Цвет текста заголовка.
    @IBInspectable open var placeholderColor: UIColor? {
        get { return textBox.placeholderLabel.textColor }
        set { textBox.placeholderLabel.textColor = newValue }
    }

    /// Цвет полоски разделителя.
    @IBInspectable open var separatorColor: UIColor? {
        get { return textBox.separatorView.backgroundColor }
        set { textBox.separatorView.backgroundColor = newValue }
    }

    /// Текст с детальным описанием.
    @IBInspectable open var detailText: String? {
        get { return textBox.detailTextLabel.text }
        set {
            textBox.detailTextLabel.text = newValue
            accessibilityLabel = newValue
        }
    }

    /// Шрифт текст с детальным описанием.
    open var detailTextFont: UIFont? {
        get { return textBox.detailTextLabel.font }
        set { textBox.detailTextLabel.font = newValue }
    }

    /// Цвет текст с детальным описанием.
    @IBInspectable open var detailTextColor: UIColor? {
        get { return textBox.detailTextLabel.textColor }
        set { textBox.detailTextLabel.textColor = newValue }
    }

    // MARK: - Init

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    /// Первичная настройка после инициализации.
    open func commonInit() {
        if let text = super.placeholder {
            super.placeholder = nil
            self.placeholder = text
        }
        textBox.frame = bounds
        addSubview(textBox)
        setupActions()
        updateState(animated: false)
        adjustsFontForContentSizeCategory = true
        rightViewMode = .always
    }

    // MARK: - Public

    @objc open func clear() {
        if delegate?.textFieldShouldClear?(self) == false { return }
        super.text = nil // в `self.text` обновление текста происходит без анимации
        detailText = nil
        updateState(animated: true)
        sendActions(for: .editingChanged)
    }

    open func setRigthView(_ view: UIView?, for state: TextInputState) {
        rightViews[state] = view
        updateState(animated: false)
    }

    open func rigthView(for state: TextInputState) -> UIView? {
        return rightViews[state]
    }

    // MARK: - UITextField

    open override var text: String? {
        didSet { updateState(animated: false) }
    }

    open override var placeholder: String? {
        get { return textBox.placeholderLabel.text }
        set { textBox.placeholderLabel.text = newValue }
    }

    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return rect.inset(by: textBox.editingTextInsets).integral
    }

    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return rect.inset(by: textBox.editingTextInsets).integral
    }

    open override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        return super.rightViewRect(forBounds: bounds.inset(by: layoutMargins))
    }

    // MARK: - UIView

    open override func layoutSubviews() {
        super.layoutSubviews()
        textBox.frame = bounds
    }

    open override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        // Чтобы не скакала высота на один пиксель
        return CGSize(width: size.width.rounded(), height: size.height.rounded())
    }

    open override func layoutMarginsDidChange() {
        super.layoutMarginsDidChange()
        textBox.layoutMargins = layoutMargins
    }

    // MARK: - Private

    private func setupActions() {
        [.editingDidBegin, .editingChanged, .editingDidEnd].forEach {
            addTarget(self, action: #selector(textDidEditing), for: $0)
        }
    }

    @objc private func textDidEditing() {
        updateState(animated: true)
    }

    private func updateState(animated: Bool) {
        let state = TextInputState(hasText: hasText, firstResponder: isFirstResponder)
        rightView = self.rigthView(for: state)
        textBox.setState(state, animated: animated)
    }
}
