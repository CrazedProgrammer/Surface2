(import lua/basic (_G dofile))

(define surface-bindings :hidden
  { :create "surface.create"
    :get-text-size "surface.getTextSize"
    :load! "surface.load"
    :load-font "surface.loadFont"
    :load-sprite-map "surface.loadSpriteMap"

    :palette/cc "surface.palette.cc"
    :palette/riko4 "surface.palette.riko4"
    :palette/redirection "surface.palette.redirection"

    :surf/clear! "surface.surf.clear"
    :surf/copy "surface.surf.copy"
    :surf/draw-arc! "surface.surf.drawArc"
    :surf/draw-ellipse! "surface.surf.drawEllipse"
    :surf/draw-line! "surface.surf.drawLine"
    :surf/draw-pixel! "surface.surf.drawPixel"
    :surf/draw-rect! "surface.surf.drawRect"
    :surf/draw-string! "surface.surf.drawString"
    :surf/draw-surface! "surface.surf.drawSurface"
    :surf/draw-surface-rotated! "surface.surf.drawSurfaceRotated"
    :surf/draw-surfaces-interlaced! "surface.surf.drawSurfacesInterlaced"
    :surf/draw-surface-small! "surface.surf.drawSurfaceSmall"
    :surf/draw-text! "surface.surf.drawText"
    :surf/draw-triangle! "surface.surf.drawTriangle"
    :surf/fill-arc! "surface.surf.fillArc"
    :surf/fill-ellipse! "surface.surf.fillEllipse"
    :surf/fill-rect! "surface.surf.fillRect"
    :surf/fill-triangle! "surface.surf.fillTriangle"
    :surf/flip! "surface.surf.flip"
    :surf/map! "surface.surf.map"
    :surf/output! "surface.surf.output"
    :surf/pop! "surface.surf.pop"
    :surf/push! "surface.surf.push"
    :surf/save! "surface.surf.save"
    :surf/shift! "surface.surf.shift"
    :surf/to-palette! "surface.surf.toPalette"
    :surf/to-rgb! "surface.surf.toRGB"

    :smap/pos "surface.smap.pos"
    :smap/sprite "surface.smap.sprite"})



(defmacro load-surface! (path (lib-name 'surface))
   @(cons `(define ,'surface-native-lib (dofile ,path))
      (let* [(output '())]
        (for-pairs (definition native) surface-bindings
          (push! output `(define ,(string->symbol (.. (symbol->string lib-name) "/" definition)) (.> ,'surface-native-lib ,@(cdr (string/split native "%."))))))
        output)))
