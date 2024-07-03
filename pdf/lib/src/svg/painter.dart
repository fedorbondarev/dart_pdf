/*
 * Copyright (C) 2017, David PHAM-VAN <dev.nfet.net@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import '../../pdf.dart';
import '../widgets/font.dart';
import 'brush.dart';
import 'color.dart';
import 'group.dart';
import 'parser.dart';

class SvgPainter {
  SvgPainter(
    this.parser,
    this._canvas,
    this.document,
    this.boundingBox,
  );

  final SvgParser parser;

  final PdfGraphics? _canvas;

  final PdfDocument document;

  final PdfRect boundingBox;

  void paint() {
    final brush = parser.colorFilter == null
        ? SvgBrush.defaultContext
        : SvgBrush.defaultContext
          .copyWith(fill: SvgColor(color: parser.colorFilter));

    SvgGroup.fromXml(parser.root, this, brush).paint(_canvas!);
  }

  final _fontCache = <String, PdfFont>{};

  PdfFont getPdfFontCache(String fontFamily, String fontStyle, String fontWeight) {
    final cache = '$fontFamily-$fontStyle-$fontWeight';

    if (!_fontCache.containsKey(cache)) {
      final pdfFont = getFont(fontFamily, fontStyle, fontWeight)?.buildFont(document) ?? getDefaultPdfFont();
      _fontCache[cache] = pdfFont;
    }

    return _fontCache[cache]!;
  }

  PdfFont getDefaultPdfFont() {
    if (document.fonts.isEmpty) {
      return PdfFont.helvetica(document);
    } else {
      return document.fonts.first;
    }
  }

  Font? getFont(String fontFamily, String fontStyle, String fontWeight) {
    switch (fontFamily) {
      case 'serif':
        switch (fontStyle) {
          case 'normal':
            switch (fontWeight) {
              case 'normal':
              case 'lighter':
                return Font.times();
            }
            return Font.timesBold();
        }
        switch (fontWeight) {
          case 'normal':
          case 'lighter':
            return Font.timesItalic();
        }
        return Font.timesBoldItalic();

      case 'monospace':
        switch (fontStyle) {
          case 'normal':
            switch (fontWeight) {
              case 'normal':
              case 'lighter':
                return Font.courier();
            }
            return Font.courierBold();
        }
        switch (fontWeight) {
          case 'normal':
          case 'lighter':
            return Font.courierOblique();
        }
        return Font.courierBoldOblique();
    }

    return null;
  }
}
