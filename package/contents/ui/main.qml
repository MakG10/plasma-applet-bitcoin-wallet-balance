/***************************************************************************
 *   Copyright (C) 2017 by MakG <makg@makg.eu>                             *
 ***************************************************************************/

import QtQuick 2.1
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import "../code/wallet.js" as Wallet

Item {
	id: root
	
	Layout.fillHeight: true
	
	property string walletBalance: '...'
	property bool showIcon: plasmoid.configuration.showIcon
	property bool showText: plasmoid.configuration.showText
	property bool updatingRate: false
	property bool configurationRequired: false
	property bool useCustomIcon: plasmoid.configuration.showIcon && plasmoid.configuration.icon != ''
	
	Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation
	Plasmoid.toolTipTextFormat: Text.RichText
	Plasmoid.backgroundHints: plasmoid.configuration.showBackground ? "StandardBackground" : "NoBackground"
	
	Plasmoid.compactRepresentation: Item {
		property int textMargin: bitcoinIcon.height * 0.25
		property int minWidth: {
			var width = 0;
			
			if(root.showIcon) width += bitcoinIcon.width;
			if(root.showText) width += walletValue.paintedWidth + textMargin;
			if(!root.showIcon) width -= textMargin;
			if(root.configurationRequired) width += configurationButton.width;
			
			return width;
		}
		
		Layout.fillWidth: false
		Layout.minimumWidth: minWidth

		MouseArea {
			id: mouseArea
			anchors.fill: parent
			hoverEnabled: true
			onClicked: {
				switch(plasmoid.configuration.onClickAction) {
					case 'website':
						action_website();
						break;
					
					case 'refresh':
					default:
						action_refresh();
						break;
				}
			}
		}
		
		BusyIndicator {
			width: parent.height
			height: parent.height
			anchors.horizontalCenter: root.showIcon ? bitcoinIcon.horizontalCenter : walletValue.horizontalCenter
			running: updatingRate
			visible: updatingRate
		}
		
		Image {
			id: bitcoinIcon
			width: parent.height * 0.9
			height: parent.height * 0.9
			anchors.top: parent.top
			anchors.left: parent.left
			anchors.topMargin: parent.height * 0.05
			anchors.leftMargin: root.showText ? parent.height * 0.05 : 0
			
			source: '../images/bitcoin-wallet.png'
			visible: root.showIcon
			opacity: root.useCustomIcon ? 0.0 : root.updatingRate ? 0.2 : mouseArea.containsMouse ? 0.8 : 1.0
		}
		
		PlasmaCore.IconItem {
			id: bitcoinIcon2
			width: parent.height * 0.9
			height: parent.height * 0.9
			anchors.top: parent.top
			anchors.left: parent.left
			anchors.topMargin: parent.height * 0.05
			anchors.leftMargin: root.showText ? parent.height * 0.05 : 0
			
			source: plasmoid.configuration.icon
			visible: root.showIcon
			opacity: root.updatingRate ? 0.2 : mouseArea.containsMouse ? 0.8 : 1.0
		}
		
		PlasmaComponents.Label {
			id: walletValue
			height: parent.height
			anchors.left: root.showIcon ? bitcoinIcon.right : parent.left
			anchors.right: parent.right
			anchors.leftMargin: root.showIcon ? textMargin : 0
			anchors.rightMargin: textMargin
			
			horizontalAlignment: root.showIcon ? Text.AlignLeft : Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
			
			visible: root.showText && !configurationRequired
			opacity: root.updatingRate ? 0.2 : mouseArea.containsMouse ? 0.8 : 1.0
			
			fontSizeMode: Text.Fit
			minimumPixelSize: bitcoinIcon.width * 0.7
			font.pixelSize: 72			
			text: root.walletBalance
		}
		
		PlasmaComponents.Button {
			id: configurationButton
			anchors.verticalCenter: root.showIcon ? bitcoinIcon.verticalCenter : parent.verticalCenter
			anchors.left: root.showIcon ? bitcoinIcon.right : parent.left
			anchors.leftMargin: root.showIcon ? textMargin : 0
			
			text: i18n("Configure...")
			visible: configurationRequired
			onClicked: plasmoid.action("configure").trigger()
		}
	}
	
	Component.onCompleted: {
		plasmoid.setAction('refresh', i18n("Refresh"), 'view-refresh')
	}
	
	Connections {
		target: plasmoid.configuration
		
		onAddressesChanged: {
			walletTimer.restart();
		}
		onCurrencyChanged: {
			walletTimer.restart();
		}
		onRefreshRateChanged: {
			walletTimer.restart();
		}
		onShowDecimalsChanged: {
			walletTimer.restart();
		}
	}
	
	Timer {
		id: walletTimer
		interval: plasmoid.configuration.refreshRate * 60 * 1000
		running: true
		repeat: true
		triggeredOnStart: true
		onTriggered: {
			var addresses = JSON.parse(plasmoid.configuration.addresses);
			addresses = addresses.map(function(element) {
				return element.address;
			});
			
			if(addresses.length === 0) {
				root.configurationRequired = true;
				return;
			}
			
			root.updatingRate = true;
			root.configurationRequired = false;
			
			var result = Wallet.getBalance(addresses, plasmoid.configuration.currency, function(balance) {
				if(!plasmoid.configuration.showDecimals) balance = Math.floor(balance);
				
				var rateText = Number(balance).toLocaleString(Qt.locale(), 'f', getPrecisionForCurrency(plasmoid.configuration.currency));
				
				if(!plasmoid.configuration.showDecimals && rateText.indexOf(Qt.locale().decimalPoint) > -1) rateText = rateText.substring(0, rateText.indexOf(Qt.locale().decimalPoint));
				rateText += ' ' +  Wallet.currencySymbols[plasmoid.configuration.currency]
				
				root.walletBalance = rateText;
				
				var toolTipSubText = '<b>' + root.walletBalance + '</b>';
				
				plasmoid.toolTipSubText = toolTipSubText;
				
				root.updatingRate = false;
			});
		}
	}
	
	function action_refresh() {
		walletTimer.restart();
	}
	
	function getPrecisionForCurrency(currency) {
		switch(currency) {
			case 'BTC':
				return 8;
				
			case 'mBTC':
				return 5;
			
			case 'Satoshi':
				return 0;
				
			default:
				return 2;
		}
	}
}
