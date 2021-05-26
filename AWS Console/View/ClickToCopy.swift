//
//  ClickToCopy.swift
//  AWS Console
//
//  Created by Anil Karaka on 26/05/2021.
//

import SwiftUI

struct ClickToCopy: View {
    @State var click = false
    var text: String
    var body: some View {
        Label(text, systemImage: "doc.on.doc")
            .onTapGesture {
                self.click = true
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (timer) in
                    self.click = false
                    }
                let pasteBoard = NSPasteboard.general
                pasteBoard.clearContents()
                pasteBoard.setString(text, forType: .string)
            }
            .foregroundColor(click ? Color.secondary : Color.primary)
            
    }
}

struct ClickToCopy_Previews: PreviewProvider {
    static var previews: some View {
        ClickToCopy(text: "Anil")
    }
}
