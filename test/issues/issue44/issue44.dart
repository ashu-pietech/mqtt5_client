import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:test/test.dart';

int main() {
  group('Main', () {
    test('Message decode fail', () {
      final messageBuffer = [
        0,
        64,
        4,
        0,
        3,
        0,
        0,
        50,
        85,
        0,
        42,
        77,
        121,
        83,
        99,
        97,
        110,
        53,
        47,
        57,
        57,
        50,
        48,
        47,
        65,
        116,
        116,
        101,
        110,
        100,
        97,
        110,
        116,
        47,
        83,
        116,
        97,
        116,
        117,
        115,
        85,
        112,
        100,
        97,
        116,
        101,
        47,
        49,
        47,
        52,
        55,
        50,
        48,
        0,
        1,
        0,
        123,
        34,
        112,
        105,
        110,
        103,
        34,
        58,
        116,
        114,
        117,
        101,
        44,
        34,
        97,
        99,
        116,
        105,
        118,
        97,
        116,
        101,
        84,
        101,
        114,
        109,
        105,
        110,
        97,
        108,
        34,
        58,
        102,
        97,
        108,
        115,
        101,
        125
      ];
      final byteBuffer = MqttByteBuffer.fromList(messageBuffer);
      final header = MqttHeader.fromByteBuffer(byteBuffer);
      expect(header.messageType, MqttMessageType.reserved1);
      try {
        MqttMessageFactory.getMessage(header, byteBuffer);
      } catch (e) {
        expect(e is MqttInvalidHeaderException, isTrue);
      }
    });

    test('Message decode OK', () {
      final messageBuffer = [
        64,
        4,
        0,
        3,
        0,
        0,
        50,
        85,
        0,
        42,
        77,
        121,
        83,
        99,
        97,
        110,
        53,
        47,
        57,
        57,
        50,
        48,
        47,
        65,
        116,
        116,
        101,
        110,
        100,
        97,
        110,
        116,
        47,
        83,
        116,
        97,
        116,
        117,
        115,
        85,
        112,
        100,
        97,
        116,
        101,
        47,
        49,
        47,
        52,
        55,
        50,
        48,
        0,
        1,
        0,
        123,
        34,
        112,
        105,
        110,
        103,
        34,
        58,
        116,
        114,
        117,
        101,
        44,
        34,
        97,
        99,
        116,
        105,
        118,
        97,
        116,
        101,
        84,
        101,
        114,
        109,
        105,
        110,
        97,
        108,
        34,
        58,
        102,
        97,
        108,
        115,
        101,
        125
      ];
      final byteBuffer = MqttByteBuffer.fromList(messageBuffer);
      final header = MqttHeader.fromByteBuffer(byteBuffer);
      expect(header.messageType, MqttMessageType.publishAck);
      final message = MqttMessageFactory.getMessage(header, byteBuffer);
      expect(message?.isValid, isTrue);
      expect(message is MqttPublishAckMessage, isTrue);
    });

    test('Message decode - multiple - one buffer', () {
      final messageBuffer = [
        64,
        4,
        0,
        3,
        0,
        50,
        85,
        0,
        42,
        77,
        121,
        83,
        99,
        97,
        110,
        53,
        47,
        57,
        57,
        50,
        48,
        47,
        65,
        116,
        116,
        101,
        110,
        100,
        97,
        110,
        116,
        47,
        83,
        116,
        97,
        116,
        117,
        115,
        85,
        112,
        100,
        97,
        116,
        101,
        47,
        49,
        47,
        52,
        55,
        50,
        48,
        0,
        1,
        0,
        123,
        34,
        112,
        105,
        110,
        103,
        34,
        58,
        116,
        114,
        117,
        101,
        44,
        34,
        97,
        99,
        116,
        105,
        118,
        97,
        116,
        101,
        84,
        101,
        114,
        109,
        105,
        110,
        97,
        108,
        34,
        58,
        102,
        97,
        108,
        115,
        101,
        125
      ];
      final messages = <MqttMessage?>[];
      var messageIndex = 0;
      final byteBuffer = MqttByteBuffer.fromList(messageBuffer);

      var header = MqttHeader.fromByteBuffer(byteBuffer);
      expect(header.messageType, MqttMessageType.publishAck);
      messages.add(MqttMessageFactory.getMessage(header, byteBuffer));
      expect(messages[messageIndex] is MqttPublishAckMessage, isTrue);
      expect(messages[messageIndex]?.isValid, isTrue);
      expect(byteBuffer.position, 0);
      messageIndex++;

      header = MqttHeader.fromByteBuffer(byteBuffer);
      expect(header.messageType, MqttMessageType.publish);
      messages.add(MqttMessageFactory.getMessage(header, byteBuffer));
      expect(messages[messageIndex] is MqttPublishMessage, isTrue);
      expect(messages[messageIndex]?.isValid, isTrue);
      expect(byteBuffer.position, 0);
      messageIndex++;
    });
  });

  group('Multi', () {
    test('Message decode - multiple - two buffers', () {
      final messageBuffer = [
        64,
        4,
        0,
        3,
        0,
        50,
        85,
      ];

      final messages = <MqttMessage?>[];
      var messageIndex = 0;
      final byteBuffer = MqttByteBuffer.fromList(messageBuffer);

      var header = MqttHeader.fromByteBuffer(byteBuffer);
      expect(header.messageType, MqttMessageType.publishAck);
      messages.add(MqttMessageFactory.getMessage(header, byteBuffer));
      print(messages[0]);
      expect(byteBuffer.isMessageAvailable(), isFalse);
      expect(messages[messageIndex] is MqttPublishAckMessage, isTrue);
      expect(messages[messageIndex]?.isValid, isTrue);
      expect(byteBuffer.position, 0);
      messageIndex++;

      byteBuffer.addAll([
        0,
        42,
        77,
        121,
        83,
        99,
        97,
        110,
        53,
        47,
        57,
        57,
        50,
        48,
        47,
        65,
        116,
        116,
        101,
        110,
        100,
        97,
        110,
        116,
        47,
        83,
        116,
        97,
        116,
        117,
        115,
        85,
        112,
        100,
        97,
        116,
        101,
        47,
        49,
        47,
        52,
        55,
        50,
        48,
        0,
        1,
        0,
        123,
        34,
        112,
        105,
        110,
        103,
        34,
        58,
        116,
        114,
        117,
        101,
        44,
        34,
        97,
        99,
        116,
        105,
        118,
        97,
        116,
        101,
        84,
        101,
        114,
        109,
        105,
        110,
        97,
        108,
        34,
        58,
        102,
        97,
        108,
        115,
        101,
        125
      ]);
      expect(byteBuffer.isMessageAvailable(), isTrue);
      header = MqttHeader.fromByteBuffer(byteBuffer);
      expect(header.messageType, MqttMessageType.publish);
      messages.add(MqttMessageFactory.getMessage(header, byteBuffer));
      expect(messages[messageIndex] is MqttPublishMessage, isTrue);
      expect(messages[messageIndex]?.isValid, isTrue);
      expect(byteBuffer.position, 0);
      byteBuffer.shrink();
      messageIndex++;
    });
  });
  return 0;
}
