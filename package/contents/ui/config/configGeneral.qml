import QtQuick 2.1
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import org.kde.plasma.components 2.0 as PlasmaComponents

import ".."

Item {
	id: configGeneral
	Layout.fillWidth: true
	
	property string cfg_addresses: plasmoid.configuration.addresses
	
	property int dialogMode: -1
	
	WalletModel {
		id: walletModel
	}
	
	Component.onCompleted: {
		walletModel.clear();
		
		var addresses = JSON.parse(cfg_addresses);
		
		for(var i = 0; i < addresses.length; i++) {
			walletModel.append(addresses[i]);
		}
	}

	RowLayout {
		anchors.fill: parent
		
		Layout.alignment: Qt.AlignTop | Qt.AlignRight
		
		TableView {
			id: addressesTable
			model: walletModel
			
			anchors.top: parent.top
			anchors.right: buttonsColumn.left
			anchors.bottom: parent.bottom
			anchors.left: parent.left
			anchors.rightMargin: 10
			
			TableViewColumn {
				role: "address"
				title: "Address"
			}
			
			TableViewColumn {
				role: "label"
				title: "Label"
			}
			
			onDoubleClicked: {
				editAddress();
			}
			
// 			onActivated: {
// 				moveUp.enabled = row > 0;
// 				moveDown.enabled = row < addressesTable.model.count - 1;
// 			}
		}
		
		ColumnLayout {
			id: buttonsColumn
			
			anchors.top: parent.top
			
			PlasmaComponents.Button {
				text: "Add..."
				iconSource: "list-add"
				
				onClicked: {
					addAddress();
				}
			}
			
			PlasmaComponents.Button {
				text: "Edit"
				iconSource: "edit-entry"
				
				onClicked: {
					editAddress();
				}
			}
			
			PlasmaComponents.Button {
				text: "Remove"
				iconSource: "list-remove"
				
				onClicked: {
					if(addressesTable.currentRow == -1) return;
					
					addressesTable.model.remove(addressesTable.currentRow);
					
					cfg_addresseses = JSON.stringify(getAddressesArray());
				}
			}
			
// 			PlasmaComponents.Button {
// 				id: moveUp
// 				text: i18n("Move up")
// 				iconSource: "go-up"
// 				enabled: false
// 				
// 				onClicked: {
// 					if(addressesTable.currentRow == -1) return;
// 					
// 					addressesTable.model.move(addressesTable.currentRow, addressesTable.currentRow - 1, 1);
// 					addressesTable.selection.clear();
// 					addressesTable.selection.select(addressesTable.currentRow - 1);
// 				}
// 			}
// 			
// 			PlasmaComponents.Button {
// 				id: moveDown
// 				text: i18n("Move down")
// 				iconSource: "go-down"
// 				enabled: false
// 				
// 				onClicked: {
// 					if(addressesTable.currentRow == -1) return;
// 					
// 					addressesTable.model.move(addressesTable.currentRow, addressesTable.currentRow + 1, 1);
// 					addressesTable.selection.clear();
// 					addressesTable.selection.select(addressesTable.currentRow + 1);
// 				}
// 			}
		}
	}
	
	
	Dialog {
		id: addressDialog
		visible: false
		title: "Address"
		standardButtons: StandardButton.Save | StandardButton.Cancel
		
		onAccepted: {
			var itemObject = {
				address: address.text,
				label: addressLabel.text
			};
			
			if(dialogMode == -1) {
				walletModel.append(itemObject);
			} else {
				walletModel.set(dialogMode, itemObject);
			}
			
			cfg_addresses = JSON.stringify(getAddressesArray());
		}

		ColumnLayout {
			GridLayout {
				columns: 2
				
				PlasmaComponents.Label {
					text: "Address:"
				}
				
				TextField {
					id: address
					Layout.minimumWidth: theme.mSize(theme.defaultFont).width * 40
				}
				
				
				PlasmaComponents.Label {
					text: "Label:"
				}
				
				TextField {
					id: addressLabel
					Layout.minimumWidth: theme.mSize(theme.defaultFont).width * 40
				}
			}
		}
	}
	
	function addAddress() {
		dialogMode = -1;
		
		address.text = ""
		addressLabel.text = ""
		
		addressDialog.visible = true;
		address.focus = true;
	}
	
	function editAddress() {
		dialogMode = addressesTable.currentRow;
		
		address.text = walletModel.get(dialogMode).address
		addressLabel.text = walletModel.get(dialogMode).label
		
		addressDialog.visible = true;
		address.focus = true;
	}
	
	function getAddressesArray() {
		var addressesArray = [];
		
		for(var i = 0; i < walletModel.count; i++) {
			addressesArray.push(walletModel.get(i));
		}
		
		return addressesArray;
	}
}
