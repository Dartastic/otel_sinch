// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_sinch/otel_sinch.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(serviceName: 'otel_sinch-test');
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('sms.batches.create records recipients + encoding + parts', () async {
    await tracedSinch<String>(
      operation: 'sms.batches.create',
      invoke: () async => const SinchCallResult(
        value: 'ok',
        result: SinchResult(
          product: 'sms',
          region: 'us',
          batchId: 'b_1',
          recipientCount: 250,
          smsType: 'mt_text',
          encoding: 'GSM',
          partCount: 1,
          deliveryStatus: 'Dispatched',
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('sinch sms.batches.create')!);
    expect(a['sinch.recipient.count'], 250);
    expect(a['sinch.sms.encoding'], 'GSM');
  });

  test('Rejected delivery sets span error', () async {
    await tracedSinch<String>(
      operation: 'sms.batches.create',
      invoke: () async => const SinchCallResult(
        value: 'ok',
        result: SinchResult(deliveryStatus: 'Rejected'),
      ),
    );
    expect(
      spans.findSpanByName('sinch sms.batches.create')!.status,
      SpanStatusCode.Error,
    );
  });

  test('failed verification sets span error', () async {
    await tracedSinch<String>(
      operation: 'verification.report',
      invoke: () async => const SinchCallResult(
        value: 'ok',
        result: SinchResult(
          product: 'verification',
          verificationId: 'v_1',
          verificationMethod: 'flashCall',
          verificationStatus: 'fail',
        ),
      ),
    );
    expect(
      spans.findSpanByName('sinch verification.report')!.status,
      SpanStatusCode.Error,
    );
  });

  test('conversation.send records channel', () async {
    await tracedSinch<String>(
      operation: 'conversation.send',
      invoke: () async => const SinchCallResult(
        value: 'ok',
        result: SinchResult(
          product: 'conversation',
          conversationId: 'c_1',
          messageChannel: 'WHATSAPP',
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('sinch conversation.send')!);
    expect(a['sinch.message.channel'], 'WHATSAPP');
  });

  test('suppression skips spans', () async {
    await runWithoutSinchInstrumentationAsync(() async {
      await tracedSinch<String>(
        operation: 'numbers.list',
        invoke: () async => const SinchCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('sinch '), isEmpty);
  });
}
