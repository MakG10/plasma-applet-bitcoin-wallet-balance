import QtQuick 2.1
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import org.kde.plasma.components 2.0 as PlasmaComponents
import "../../code/wallet.js" as Wallet

Item {
	id: configAppearance
	Layout.fillWidth: true
	
	property string cfg_currency: plasmoid.configuration.currency
	property alias cfg_refreshRate: refreshRate.value
	property alias cfg_showIcon: showIcon.checked
	property string cfg_icon: plasmoid.configuration.icon
	property alias cfg_showText: showText.checked
	property alias cfg_showDecimals: showDecimals.checked
	property alias cfg_showBackground: showBackground.checked
	property variant currencyList: { Wallet.getAllCurrencies() }
	
	GridLayout {
		columns: 2
		
		Label {
			text: i18n("Currency:")
		}
		
		ComboBox {
			id: currency
			model: currencyList
			Layout.minimumWidth: theme.mSize(theme.defaultFont).width * 15
			onActivated: {
				cfg_currency = currency.textAt(index)
			}
			Component.onCompleted: {
				var currencyIndex = currency.find(plasmoid.configuration.currency)
				
				if(currencyIndex != -1) {
					currency.currentIndex = currencyIndex
				}
			}
		}
		
		Label {
			text: i18n("Refresh rate:")
		}
		
		SpinBox {
			id: refreshRate
			suffix: i18n(" minutes")
			minimumValue: 1
		}
		
		Label {
			text: ""
		}
		
		CheckBox {
			id: showIcon
			text: i18n("Show icon")
			onClicked: {
				if(!this.checked) {
					showText.checked = true
					showText.enabled = false
				} else {
					showText.enabled = true
				}
			}
		}
		
		PlasmaComponents.Label {
			text: i18n("Icon:")
		}
		
		IconPicker {
			currentIcon: cfg_icon
			defaultIcon: ""
			onIconChanged: cfg_icon = iconName
			enabled: true
		}
		
		Label {
			text: ""
		}
		
		CheckBox {
			id: showText
			text: i18n("Show text (when disabled, the rate is visible on hover)")
			onClicked: {
				if(!this.checked) {
					showIcon.checked = true
					showIcon.enabled = false
				} else {
					showIcon.enabled = true
				}
			}
		}
		
		Label {
			text: ""
		}
		
		CheckBox {
			id: showDecimals
			text: i18n("Show decimals")
		}
		
		Label {
			text: ""
		}
		
		CheckBox {
			id: showBackground
			text: i18n("Show background")
		}
	}
}
