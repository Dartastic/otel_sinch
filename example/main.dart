// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_sinch/otel_sinch.dart';

/// Traces Sinch calls with OpenTelemetry.
///
/// `otel_sinch` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Sinch call in
/// [tracedSinch]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'sinch-example');

  // Wraps a Sinch API call in a CLIENT span.
  final sinchId = await tracedSinch<String>(
    operation: 'sms.batches.create',
    invoke: () async {
      // Make the Sinch call here, then report what it returned.
      const id = 'sinch_8f3a2c';
      return const SinchCallResult(
          value: id,
          result: SinchResult(
              product: 'sms',
              region: 'us',
              servicePlanId: 'serviceplan_8f3a2c',
              from: 'example',
              to: 'example',
              countryCode: 'example',
              batchId: 'batch_8f3a2c',
              recipientCount: 3,
              smsType: 'mt_text',
              deliveryStatus: 'Queued',
              encoding: 'GSM',
              partCount: 3,
              smsPriceMicros: 120,
              callId: 'call_8f3a2c',
              callType: 'mxp',
              callStatus: 'ongoing',
              callDurationSec: 120,
              verificationId: 'verification_8f3a2c',
              verificationStatus: 'pending',
              verificationMethod: 'sms',
              conversationId: 'conversation_8f3a2c',
              messageChannel: 'WHATSAPP',
              conversationAppId: 'conversationapp_8f3a2c',
              errorCode: '40001',
              errorMessage: 'example',
              statusCode: 201));
    },
  );
  OTelLog.info('tracedSinch sms.batches.create returned $sinchId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutSinchInstrumentationAsync.
  await runWithoutSinchInstrumentationAsync(
    () => tracedSinch<String>(
      operation: 'sms.batches.create',
      invoke: () async {
        const id = 'sinch_8f3a2c';
        return const SinchCallResult(
            value: id,
            result: SinchResult(
                product: 'sms',
                region: 'us',
                servicePlanId: 'serviceplan_8f3a2c',
                from: 'example',
                to: 'example',
                countryCode: 'example',
                batchId: 'batch_8f3a2c',
                recipientCount: 3,
                smsType: 'mt_text',
                deliveryStatus: 'Queued',
                encoding: 'GSM',
                partCount: 3,
                smsPriceMicros: 120,
                callId: 'call_8f3a2c',
                callType: 'mxp',
                callStatus: 'ongoing',
                callDurationSec: 120,
                verificationId: 'verification_8f3a2c',
                verificationStatus: 'pending',
                verificationMethod: 'sms',
                conversationId: 'conversation_8f3a2c',
                messageChannel: 'WHATSAPP',
                conversationAppId: 'conversationapp_8f3a2c',
                errorCode: '40001',
                errorMessage: 'example',
                statusCode: 201));
      },
    ),
  );

  await OTel.shutdown();
}
