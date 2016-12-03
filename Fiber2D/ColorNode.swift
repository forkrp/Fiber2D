//
//  ColorNode.swift
//
//  Created by Andrey Volodin on 06.07.16.
//  Copyright © 2016. All rights reserved.
//

import SwiftMath
import SwiftBGFX

/**
 Draws a rectangle filled with a solid color.
 */
open class ColorNode: Node {
    /**
     *  Creates a node with color, width and height in Points.
     *
     *  @param color Color of the node.
     *  @param size  Width and Height of the node.
     *
     *  @return An initialized ColorNode Object.
     *  @see Color
     */
    public init(color: Color = .clear, size: Size = .zero) {
        super.init()
        self.color = color
        self.contentSizeInPoints = size
    
        self.renderComponent = BackgroundColorRenderComponent(size: size, color: color)
    }
    
    override public var color: Color {
        didSet {
            updateColor()
        }
    }
    
    override public var opacity: Float {
        didSet {
            updateColor()
        }
    }
    
    override func updateDisplayedOpacity(_ parentOpacity: Float) {
        super.updateDisplayedOpacity(parentOpacity)
        updateColor()
    }
    
    internal func updateColor() {
        renderComponent?.geometry.color = displayedColor.premultiplyingAlpha
    }
}

public class BackgroundColorRenderComponent: QuadRenderer {
    
    public init(size: Size, color: Color) {
        let vertices = [
            RendererVertex(position: vec4(0, 0, 0, 1),
                           texCoord1: .zero, texCoord2: .zero,
                           color: color),
            RendererVertex(position: vec4(size.width, 0, 0, 1),
                           texCoord1: .zero, texCoord2: .zero,
                           color: color),
            RendererVertex(position: vec4(size.width, size.height, 0, 1),
                           texCoord1: .zero, texCoord2: .zero,
                           color: color),
            RendererVertex(position: vec4(0, size.height, 0, 1),
                           texCoord1: .zero, texCoord2: .zero,
                           color: color)]
        
        // Index buffer is ignored
        let geometry = Geometry(vertexBuffer: vertices, indexBuffer: [])
        super.init(material: Material(technique: .positionColor), geometry: geometry)
    }
    
    public override func onAdd(to owner: Node) {
        super.onAdd(to: owner)
        owner.onContentSizeInPointsChanged.subscribe(on: self) {
            self.update(for: $0)
        }
    }
    
    public override func onRemove() {
        // Do it before super, as it assigns owner to nil
        owner?.onContentSizeInPointsChanged.cancelSubscription(for: self)
        super.onRemove()
    }
    
    public func update(for size: Size) {
        geometry.positions = [vec4(0, 0, 0, 1),
                              vec4(size.width, 0, 0, 1),
                              vec4(size.width, size.height, 0, 1),
                              vec4(0, size.height, 0, 1)]
    }
}
