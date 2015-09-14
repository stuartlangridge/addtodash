import QtQuick 2.0
import Ubuntu.Components 1.2

import "database.js" as Database

Page {
    id: detailsPage
    visible: false

    title: newUrl ? i18n.tr("Add Bookmark") : i18n.tr("Edit Bookmark")
    property alias url: urlField.text
    property alias bookmarkTitle: titleField.text
    property string icon: ""
    property int favorite: 0
    property bool newUrl: false
    property string state: "editing"

    function close(wasModified) {
        if (wasModified)
            overviewPage.loadBookmarks()
        stack.pop()
    }

    Component.onCompleted: {
        if (newUrl) {
            state = "loading"
            webview.url = url
        }
    }

    HiddenWebView {
        id: webview

        function parsingCallback(msg, frame) {
            console.log("got message", JSON.stringify(msg.args));
            if (detailsPage.state == "loading") {
                bookmarkTitle = msg.args.short_name;
                if (msg.args.icons && msg.args.icons.length > 1)
                    icon = webview.chooseBestIcon(msg.args.icons);
                detailsPage.state = "editing"
            }
        }
    }

    Column {
        id: mainColumn
        spacing: units.gu(1)
        width: Math.min(parent.width, units.gu(50))
        anchors {
            margins: units.gu(2)
            top: parent.top
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }

        property real labelWidth: units.gu(8)

        Item {
            width: parent.width
            height: urlField.height

            Label {
                id: urlLabel
                text: i18n.tr("URL")
                width: mainColumn.labelWidth
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
            }

            TextField {
                id: urlField
                anchors {
                    left: urlLabel.right
                    right: parent.right
                }
            }
        }

        Item {
            id: titleItem
            visible: detailsPage.state == "editing"
            width: parent.width
            height: titleField.height

            Label {
                id: titleLabel
                text: i18n.tr("Title")
                width: mainColumn.labelWidth
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
            }

            TextField {
                id: titleField
                anchors {
                    left: titleLabel.right
                    right: parent.right
                }
            }
        }

        Row {
            id: iconItem
            visible: detailsPage.state == "editing"

            Label {
                text: i18n.tr("Icon")
                width: mainColumn.labelWidth
                anchors.verticalCenter: parent.verticalCenter
            }

            UbuntuShape {
                id: iconShape
                source: Image {
                    asynchronous: true
                    fillMode: Image.PreserveAspectCrop
                    clip: true
                    source: detailsPage.icon ||
                            "file:///usr/share/icons/suru/actions/scalable/stock_website.svg"
                }
            }
        }

        Item {
            id: buttonItem
            visible: detailsPage.state == "editing"
            height: childrenRect.height
            width: parent.width

            Button {
                width: parent.width/2 - units.gu(1)
                anchors.left: parent.left
                text: i18n.tr("Cancel")
                color: UbuntuColors.red

                onClicked: detailsPage.close(false)
            }

            Button {
                width: parent.width/2 - units.gu(1)
                anchors.right: parent.right
                text: i18n.tr("Save")
                color: UbuntuColors.green

                onClicked: {
                    Database.addBookmark(detailsPage.url, detailsPage.bookmarkTitle,
                                         detailsPage.icon, detailsPage.favorite)
                    detailsPage.close(true)
                }
            }
        }

        Item {
            width: parent.width
            height: units.gu(20)
            visible: detailsPage.state == "loading"

            ActivityIndicator {
                id: indicator
                anchors {
                    top: parent.top
                    topMargin: units.gu(5)
                    horizontalCenter: parent.horizontalCenter
                }
                running: detailsPage.state == "loading"
            }

            Label {
                anchors {
                    top: indicator.bottom
                    horizontalCenter: parent.horizontalCenter
                }
                text: i18n.tr("Loading page...")
            }

            Button {
                width: parent.width/2
                anchors {
                    bottom: parent.bottom
                    horizontalCenter: parent.horizontalCenter
                }
                text: i18n.tr("Cancel")
                color: UbuntuColors.red

                onClicked: detailsPage.state = "editing"
            }
        }
    }
}
