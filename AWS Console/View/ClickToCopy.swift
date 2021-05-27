//
//  ClickToCopy.swift
//  AWS Console
//
//  Created by Anil Karaka on 26/05/2021.
//

import SwiftUI

struct ClickToCopy: View {
    @State var click = false
    var title: String
    var text: String
    var clickToCopy = true
    var body: some View {
        HStack {
            if title != "" {
            Text("\(title): ")
                .bold()
            }
            clickToCopy ? AnyView(Label(text, systemImage: "doc.on.doc")
                .onTapGesture {
                    self.click = true
                    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (timer) in
                        self.click = false
                        }
                    let pasteBoard = NSPasteboard.general
                    pasteBoard.clearContents()
                    pasteBoard.setString(text, forType: .string)
                }
                .foregroundColor(click ? Color.secondary : Color.primary)
                ) : AnyView(Text(text))
        }
            
    }
}

struct CustomLabel: View {
    var title: String
    var text: String
    var body: some View{
        HStack{
            Text("\(title): ")
                .bold()
            Text(text)
        }
    }
}

struct ClickToCopy_Previews: PreviewProvider {
    static var previews: some View {
        ClickToCopy(title: "Test", text: "Anilasdfa")
    }
}
