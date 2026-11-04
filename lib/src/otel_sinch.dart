// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_sinch_suppression.dart';

const _tracerName = 'dartastic_otel_libs_sinch';

APITracer _tracer() => OTelAPI.tracerProvider().getTracer(_tracerName);

class SinchResult {
  /// Creates a result.
  const SinchResult({
    this.product,
    this.region,
    this.servicePlanId,
    this.from,
    this.to,
    this.countryCode,
    this.batchId,
    this.recipientCount,
    this.smsType,
    this.deliveryStatus,
    this.encoding,
    this.partCount,
    this.smsPriceMicros,
    this.callId,
    this.callType,
    this.callStatus,
    this.callDurationSec,
    this.verificationId,
    this.verificationStatus,
    this.verificationMethod,
    this.conversationId,
    this.messageChannel,
    this.conversationAppId,
    this.errorCode,
    this.errorMessage,
    this.statusCode,
  });

  /// `sms`, `mms`, `voice`, `verification`, `conversation`, `numbers`,
  /// `flow`, `whatsapp`, `viber`, `rcs`, `messenger`, `email`,
  /// `instagram`.
  final String? product;

  /// `us`, `eu`, `br`, `au`, `ca`.
  final String? region;

  /// SMS service plan id.
  final String? servicePlanId;

  final String? from;
  final String? to;

  /// ISO 3166-1 alpha-2.
  final String? countryCode;

  // ── SMS Batch ──────────────────────────────────────────────────
  final String? batchId;
  final int? recipientCount;

  /// `mt_text`, `mt_binary`, `mt_media`, `mo_text`, `mo_binary`.
  final String? smsType;

  /// `Queued`, `Dispatched`, `Aborted`, `Rejected`, `Failed`, `Delivered`,
  /// `Expired`, `Unknown`.
  final String? deliveryStatus;

  /// `GSM`, `UCS-2`.
  final String? encoding;

  /// Number of SMS segments.
  final int? partCount;

  /// SMS unit price in millionths.
  final int? smsPriceMicros;

  // ── Voice ──────────────────────────────────────────────────────
  final String? callId;

  /// `mxp` (managed-XML), `conf`, `data`, `pstn`.
  final String? callType;

  /// `ongoing`, `final`, `failed`, `busy`, `no_answer`, `disconnected`.
  final String? callStatus;

  final int? callDurationSec;

  // ── Verification ───────────────────────────────────────────────
  final String? verificationId;

  /// `pending`, `successful`, `fail`, `denied`, `aborted`.
  final String? verificationStatus;

  /// `sms`, `flashCall`, `callout`, `seamless`.
  final String? verificationMethod;

  // ── Conversation API ───────────────────────────────────────────
  final String? conversationId;

  /// `WHATSAPP`, `RCS`, `MESSENGER`, `INSTAGRAM`, `LINE`, `VIBER`,
  /// `VIBERBM`, `KAKAOTALK`, `KAKAOTALKCHAT`, `MMS`, `SMS`, `TELEGRAM`,
  /// `EMAIL`.
  final String? messageChannel;

  final String? conversationAppId;

  /// Sinch error code (`40001` validation_error, `40101` invalid_authentication,
  /// `40301` forbidden, `40401` not_found, `42201` invalid_phone,
  /// `42901` rate_limited, `50001` internal_error).
  final String? errorCode;
  final String? errorMessage;
  final int? statusCode;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class SinchCallResult<T> {
  /// Creates a call result.
  const SinchCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final SinchResult? result;
}

/// Wraps a Sinch API call in a CLIENT span. [operation] is one of
/// `sms.batches.create`, `sms.batches.get`, `sms.batches.cancel`,
/// `sms.batches.dryRun`, `sms.batches.replaceDelivery`,
/// `sms.inbounds.list`, `sms.inbounds.get`, `sms.groups.create`,
/// `sms.groups.update`, `sms.groups.delete`, `voice.callouts.dial`,
/// `voice.callouts.tts`, `voice.callouts.conference`, `voice.calls.update`,
/// `voice.calls.get`, `voice.calls.management.hangup`,
/// `verification.start`, `verification.report`, `verification.get`,
/// `conversation.send`, `conversation.list`, `conversation.update`,
/// `conversation.contacts.create`, `conversation.apps.list`,
/// `numbers.list`, `numbers.rent`, `numbers.release`, `numbers.search`,
/// `flow.run`, `mailgun.send`.
Future<T> tracedSinch<T>({
  required String operation,
  required Future<SinchCallResult<T>> Function() invoke,
}) async {
  if (sinchInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'sinch',
    'rpc.method': operation,
    'sinch.operation': operation,
  };

  final span = _tracer().startSpan(
    'sinch $operation',
    kind: SpanKind.client,
    attributes: OTelAPI.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final res = r.result!;
      final extras = <Attribute<Object>>[];
      if (res.product != null) {
        extras.add(OTelAPI.attributeString('sinch.product', res.product!));
      }
      if (res.region != null) {
        extras.add(OTelAPI.attributeString('sinch.region', res.region!));
      }
      if (res.servicePlanId != null) {
        extras.add(OTelAPI.attributeString(
          'sinch.service_plan.id',
          res.servicePlanId!,
        ));
      }
      if (res.from != null) {
        extras.add(OTelAPI.attributeString('sinch.from', res.from!));
      }
      if (res.to != null) {
        extras.add(OTelAPI.attributeString('sinch.to', res.to!));
      }
      if (res.countryCode != null) {
        extras.add(OTelAPI.attributeString(
          'sinch.country_code',
          res.countryCode!,
        ));
      }
      if (res.batchId != null) {
        extras.add(OTelAPI.attributeString('sinch.batch.id', res.batchId!));
      }
      if (res.recipientCount != null) {
        extras.add(OTelAPI.attributeInt(
          'sinch.recipient.count',
          res.recipientCount!,
        ));
      }
      if (res.smsType != null) {
        extras.add(OTelAPI.attributeString('sinch.sms.type', res.smsType!));
      }
      if (res.deliveryStatus != null) {
        extras.add(OTelAPI.attributeString(
          'sinch.delivery.status',
          res.deliveryStatus!,
        ));
        if (res.deliveryStatus == 'Failed' ||
            res.deliveryStatus == 'Rejected' ||
            res.deliveryStatus == 'Aborted' ||
            res.deliveryStatus == 'Expired') {
          span.setStatus(
            SpanStatusCode.Error,
            'Sinch delivery ${res.deliveryStatus}',
          );
        }
      }
      if (res.encoding != null) {
        extras.add(OTelAPI.attributeString(
          'sinch.sms.encoding',
          res.encoding!,
        ));
      }
      if (res.partCount != null) {
        extras.add(OTelAPI.attributeInt('sinch.sms.parts', res.partCount!));
      }
      if (res.smsPriceMicros != null) {
        extras.add(OTelAPI.attributeInt(
          'sinch.sms.price_micros',
          res.smsPriceMicros!,
        ));
      }
      if (res.callId != null) {
        extras.add(OTelAPI.attributeString('sinch.call.id', res.callId!));
      }
      if (res.callType != null) {
        extras.add(OTelAPI.attributeString('sinch.call.type', res.callType!));
      }
      if (res.callStatus != null) {
        extras.add(OTelAPI.attributeString(
          'sinch.call.status',
          res.callStatus!,
        ));
        if (res.callStatus == 'failed' || res.callStatus == 'disconnected') {
          span.setStatus(
            SpanStatusCode.Error,
            'Sinch call ${res.callStatus}',
          );
        }
      }
      if (res.callDurationSec != null) {
        extras.add(OTelAPI.attributeInt(
          'sinch.call.duration_sec',
          res.callDurationSec!,
        ));
      }
      if (res.verificationId != null) {
        extras.add(OTelAPI.attributeString(
          'sinch.verification.id',
          res.verificationId!,
        ));
      }
      if (res.verificationStatus != null) {
        extras.add(OTelAPI.attributeString(
          'sinch.verification.status',
          res.verificationStatus!,
        ));
        if (res.verificationStatus == 'fail' ||
            res.verificationStatus == 'denied') {
          span.setStatus(
            SpanStatusCode.Error,
            'Sinch verify ${res.verificationStatus}',
          );
        }
      }
      if (res.verificationMethod != null) {
        extras.add(OTelAPI.attributeString(
          'sinch.verification.method',
          res.verificationMethod!,
        ));
      }
      if (res.conversationId != null) {
        extras.add(OTelAPI.attributeString(
          'sinch.conversation.id',
          res.conversationId!,
        ));
      }
      if (res.messageChannel != null) {
        extras.add(OTelAPI.attributeString(
          'sinch.message.channel',
          res.messageChannel!,
        ));
      }
      if (res.conversationAppId != null) {
        extras.add(OTelAPI.attributeString(
          'sinch.conversation.app_id',
          res.conversationAppId!,
        ));
      }
      if (res.errorCode != null) {
        extras.add(OTelAPI.attributeString(
          'sinch.error.code',
          res.errorCode!,
        ));
        span.setStatus(SpanStatusCode.Error, 'Sinch ${res.errorCode}');
      }
      if (res.errorMessage != null) {
        extras.add(OTelAPI.attributeString(
          'sinch.error.message',
          res.errorMessage!,
        ));
      }
      if (res.statusCode != null) {
        extras.add(OTelAPI.attributeInt(
          'http.response.status_code',
          res.statusCode!,
        ));
        if (res.statusCode! >= 400) {
          span.setStatus(SpanStatusCode.Error, 'Sinch HTTP ${res.statusCode}');
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTelAPI.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTelAPI.attributes([
      OTelAPI.attributeString(
        ErrorAttributes.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
