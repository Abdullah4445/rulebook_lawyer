import 'dart:convert';

import 'package:driver/model/driver_user_model.dart';
import 'package:driver/model/payment_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:payfast_flutter/payfast_flutter.dart';

class PayFastCheckoutHelper {
  static const String _tokenEndpoint =
      'https://ipg1.apps.net.pk/Ecommerce/api/Transaction/GetAccessToken';
  static const String defaultMerchantId = '241665';
  static const String defaultSecuredKey = 'stqiinqRfCjySfx00J9ySIzIR';
  static const String defaultGatewayName = 'PayFast';

  static Payfast normalizePayfast(Payfast? payfast) {
    final Payfast normalized = payfast ?? Payfast();
    normalized.merchantId = resolveMerchantId(normalized);
    normalized.securedKey = resolveSecuredKey(normalized);
    normalized.name = normalized.name?.trim().isNotEmpty == true
        ? normalized.name!.trim()
        : defaultGatewayName;
    normalized.currencyCode = resolveCurrencyCode(normalized);
    normalized.enable = true;
    return normalized;
  }

  static String resolveMerchantId(Payfast payfast) {
    final String merchantId = payfast.merchantId?.trim() ?? '';
    if (merchantId.isNotEmpty) {
      return merchantId;
    }
    return defaultMerchantId;
  }

  static String resolveSecuredKey(Payfast payfast) {
    final String securedKey = payfast.securedKey?.trim() ?? '';
    if (securedKey.isNotEmpty) {
      return securedKey;
    }
    final String merchantKey = payfast.merchantKey?.trim() ?? '';
    if (merchantKey.isNotEmpty) {
      return merchantKey;
    }
    return defaultSecuredKey;
  }

  static String resolveCurrencyCode(Payfast payfast) {
    final String currencyCode = payfast.currencyCode?.trim() ?? '';
    if (currencyCode.isNotEmpty) {
      return currencyCode;
    }
    return 'PKR';
  }

  static String resolveCallbackBaseUrl(Payfast payfast) {
    final List<String> candidates = [
      payfast.returnUrl?.trim() ?? '',
      payfast.cancelUrl?.trim() ?? '',
      payfast.notifyUrl?.trim() ?? '',
    ];

    for (final rawUrl in candidates) {
      if (rawUrl.isEmpty) {
        continue;
      }

      final Uri? uri = Uri.tryParse(rawUrl);
      if (uri != null && uri.hasScheme && uri.host.isNotEmpty) {
        final String port = uri.hasPort ? ':${uri.port}' : '';
        return '${uri.scheme}://${uri.host}$port';
      }
    }

    return '';
  }

  static String _resolveUrlPath(String? rawUrl, String fallbackPath) {
    final String value = rawUrl?.trim() ?? '';
    if (value.isEmpty) {
      return fallbackPath;
    }

    final Uri? uri = Uri.tryParse(value);
    if (uri == null) {
      return fallbackPath;
    }

    String path = uri.path.isNotEmpty ? uri.path : fallbackPath;
    if (!path.startsWith('/')) {
      path = '/$path';
    }

    if (uri.query.isNotEmpty) {
      path = '$path?${uri.query}';
    }

    return path;
  }

  static String resolveSuccessPath(Payfast payfast) {
    return _resolveUrlPath(payfast.returnUrl, '/payfast-success');
  }

  static String resolveFailurePath(Payfast payfast) {
    return _resolveUrlPath(payfast.cancelUrl, '/payfast-failure');
  }

  static String resolveCheckoutPath(Payfast payfast) {
    return _resolveUrlPath(payfast.notifyUrl, '/payfast-ipn');
  }

  static String? resolveWebTokenUrl(Payfast payfast) {
    final String notifyUrl = payfast.notifyUrl?.trim() ?? '';
    if (notifyUrl.isEmpty) {
      return null;
    }
    return notifyUrl;
  }

  static String resolveCustomerEmail(DriverUserModel userModel) {
    return userModel.email?.trim() ?? '';
  }

  static String resolveCustomerMobile(DriverUserModel userModel) {
    return userModel.phoneNumber?.trim() ?? '';
  }

  static String? validateSettings(Payfast? payfast) {
    final Payfast normalized = normalizePayfast(payfast);
    if (normalized.enable != true) {
      return 'PayFast is not enabled.';
    }
    if (resolveMerchantId(normalized).isEmpty) {
      return 'PayFast merchant ID is missing.';
    }
    if (resolveSecuredKey(normalized).isEmpty) {
      return 'PayFast secured key is missing.';
    }
    if (resolveCallbackBaseUrl(normalized).isEmpty) {
      return 'PayFast callback base URL is missing.';
    }
    if (kIsWeb && (resolveWebTokenUrl(normalized)?.isEmpty ?? true)) {
      return 'PayFast web token URL is missing.';
    }
    return null;
  }

  static Future<String?> validateGatewayCredentials({
    required Payfast? payfast,
    required String basketId,
    required String amount,
  }) async {
    final Payfast normalized = normalizePayfast(payfast);

    try {
      final response = await http.post(
        Uri.parse(_tokenEndpoint),
        body: {
          'MERCHANT_ID': resolveMerchantId(normalized),
          'SECURED_KEY': resolveSecuredKey(normalized),
          'BASKET_ID': basketId,
          'TXNAMT': amount,
          'CURRENCY_CODE': resolveCurrencyCode(normalized),
        },
      );

      if (response.statusCode != 200) {
        return 'PayFast token request failed (HTTP ${response.statusCode}).';
      }

      if (response.body.trim().isEmpty) {
        return 'PayFast token response was empty.';
      }

      final dynamic data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        final String accessToken = (data['ACCESS_TOKEN'] ?? '').toString().trim();
        if (accessToken.isNotEmpty) {
          return null;
        }

        final String errorDescription =
            (data['errorDescription'] ?? data['message'] ?? '').toString().trim();
        final String errorCode = (data['errorCode'] ?? '').toString().trim();

        if (errorDescription.isNotEmpty) {
          return errorCode.isNotEmpty
              ? 'PayFast error $errorCode: $errorDescription'
              : errorDescription;
        }
      }

      return 'PayFast did not return a valid access token.';
    } catch (e) {
      return 'Unable to verify PayFast credentials: $e';
    }
  }

  static PayFastConfig buildConfig({
    required Payfast payfast,
    required DriverUserModel userModel,
    required String basketId,
    required String amount,
    required String transactionDescription,
    required String additionalDescription,
  }) {
    final Payfast normalized = normalizePayfast(payfast);
    return PayFastConfig(
      merchantId: resolveMerchantId(normalized),
      securedKey: resolveSecuredKey(normalized),
      basketId: basketId,
      amount: amount,
      currency: resolveCurrencyCode(normalized),
      txnDesc: transactionDescription,
      customerEmail: resolveCustomerEmail(userModel),
      customerMobile: resolveCustomerMobile(userModel),
      successUrl: normalized.returnUrl?.trim() ?? '',
      failureUrl: normalized.cancelUrl?.trim() ?? '',
      checkoutUrl: normalized.notifyUrl?.trim() ?? '',
      environment: normalized.isSandbox == true ? 'sandbox' : 'live',
      additionalDescription: additionalDescription,
    );
  }
}

