/*
 * Copyright (c) 2019 Meltytech, LLC
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import Shotcut.Controls 1.0

KeyframableFilter {
    
    property string amplitude: '0'
    property string frequency: '1'
    property string useVelocity: '2'
    property string velocity: '3'
    property double amplitudeDefault: 0.5
    property double frequencyDefault: 0.005
    property double velocityDefault: 0.5

    keyframableParameters: [amplitude, frequency, velocity]
    startValues: [0, 0, 0]
    middleValues: [amplitudeDefault, frequencyDefault, velocityDefault]
    endValues: [0, 0, 0]

    width: 350
    height: 150
    
    Component.onCompleted: {
        if (filter.isNew) {
            filter.set(amplitude, amplitudeDefault)
            filter.set(frequency, frequencyDefault)
            filter.set(useVelocity, 1)
            filter.set(velocity, velocityDefault)
            filter.savePreset(preset.parameters)
        }
        setControls()
    }

    function setControls() {
        var position = getPosition()
        blockUpdate = true
        amplitudeSlider.value = filter.getDouble(amplitude, position) * amplitudeSlider.maximumValue
        frequencySlider.value = filter.getDouble(frequency, position) * frequencySlider.maximumValue
        velocitySlider.value = filter.getDouble(velocity, position) * velocitySlider.maximumValue
        blockUpdate = false
        enableControls(isSimpleKeyframesActive())
    }

    function enableControls(enabled) {
        amplitudeSlider.enabled = frequencySlider.enabled = velocitySlider.enabled = enabled
    }

    function updateSimpleKeyframes() {
        updateFilter(amplitude, amplitudeSlider.value / amplitudeSlider.maximumValue, amplitudeKeyframesButton)
        updateFilter(frequency, frequencySlider.value / frequencySlider.maximumValue, frequencyKeyframesButton)
        updateFilter(velocity, velocitySlider.value / velocitySlider.maximumValue, velocityKeyframesButton)
    }

    GridLayout {
        anchors.fill: parent
        anchors.margins: 8
        columns: 4

        Label {
            text: qsTr('Preset')
            Layout.alignment: Qt.AlignRight
        }
        Preset {
            id: preset
            parameters: [amplitude, frequency, useVelocity, velocity]
            Layout.columnSpan: 3
            onBeforePresetLoaded: {
                resetSimpleKeyframes()
            }
            onPresetSelected: {
                setControls()
                initializeSimpleKeyframes()
            }
        }

        Label {
            text: qsTr('Amplitude')
            Layout.alignment: Qt.AlignRight
        }
        SliderSpinner {
            id: amplitudeSlider
            minimumValue: 0
            maximumValue: 100
            stepSize: 0.1
            decimals: 1
            suffix: ' %'
            onValueChanged: updateFilter(amplitude, value / maximumValue, amplitudeKeyframesButton, getPosition())
        }
        UndoButton {
            onClicked: amplitudeSlider.value = amplitudeDefault * amplitudeSlider.maximumValue
        }
        KeyframesButton {
            id: amplitudeKeyframesButton
            checked: filter.animateIn <= 0 && filter.animateOut <= 0 && filter.keyframeCount(amplitude) > 0
            onToggled: {
                enableControls(true)
                toggleKeyframes(checked, amplitude, amplitudeSlider.value / amplitudeSlider.maximumValue)
            }
        }

        Label {
            text: qsTr('Frequency')
            Layout.alignment: Qt.AlignRight
        }
        SliderSpinner {
            id: frequencySlider
            minimumValue: 0
            maximumValue: 100
            stepSize: 0.1
            decimals: 1
            suffix: ' %'
            onValueChanged: updateFilter(frequency, value / maximumValue, frequencyKeyframesButton, getPosition())
        }
        UndoButton {
            onClicked: frequencySlider.value = frequencyDefault * frequencySlider.maximumValue
        }
        KeyframesButton {
            id: frequencyKeyframesButton
            checked: filter.animateIn <= 0 && filter.animateOut <= 0 && filter.keyframeCount(frequency) > 0
            onToggled: {
                enableControls(true)
                toggleKeyframes(checked, frequency, frequencySlider.value / frequencySlider.maximumValue)
            }
        }

        Label {
            text: qsTr('Velocity')
            Layout.alignment: Qt.AlignRight
        }
        SliderSpinner {
            id: velocitySlider
            minimumValue: 0
            maximumValue: 100
            stepSize: 0.1
            decimals: 1
            suffix: ' %'
            onValueChanged: updateFilter(velocity, value / maximumValue, velocityKeyframesButton, getPosition())
        }
        UndoButton {
            onClicked: velocitySlider.value = velocityDefault * velocitySlider.maximumValue
        }
        KeyframesButton {
            id: velocityKeyframesButton
            checked: filter.animateIn <= 0 && filter.animateOut <= 0 && filter.keyframeCount(velocity) > 0
            onToggled: {
                enableControls(true)
                toggleKeyframes(checked, velocity, velocitySlider.value / velocitySlider.maximumValue)
            }
        }

        Item {
            Layout.fillHeight: true;
        }
    }

    Connections {
        target: filter
        onInChanged: updateSimpleKeyframes()
        onOutChanged: updateSimpleKeyframes()
        onAnimateInChanged: updateSimpleKeyframes()
        onAnimateOutChanged: updateSimpleKeyframes()
    }

    Connections {
        target: producer
        onPositionChanged: setControls()
    }
}
