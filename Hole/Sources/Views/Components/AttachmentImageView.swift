import SwiftUI

struct AttachmentImageView: View {
    let attachment: ImageAttachment
    var height: CGFloat = 180

    var body: some View {
        if let url = AttachmentStorage.absoluteURL(forRelative: attachment.fileURL),
           let image = UIImage(contentsOfFile: url.path) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .clipped()
        } else {
            Rectangle()
                .fill(.gray.opacity(0.3))
                .frame(height: height)
                .overlay {
                    Image(systemName: "photo")
                        .foregroundStyle(.secondary)
                }
        }
    }
}
