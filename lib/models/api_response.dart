class ApiResponse<T> {
  final String status;
  final String message;
  final T? data;

  ApiResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJson) {
    final statusRaw = json['status'] ?? json['success'];
    final status = statusRaw is bool
        ? (statusRaw ? 'Success' : 'Error')
        : statusRaw?.toString() ?? 'Error';
    final message = json['message'] ?? json['msg'] ?? json['error'] ?? '';
    final dynamic payload = json.containsKey('data')
        ? json['data']
        : json.containsKey('user')
            ? json['user']
            : json;

    return ApiResponse(
      status: status,
      message: message,
      data: payload != null ? fromJson(payload) : null,
    );
  }
}

class PaginatedResponse<T> {
  final int currentPage;
  final List<T> data;
  final String? firstPageUrl;
  final int? from;
  final int lastPage;
  final String? lastPageUrl;
  final List<Link> links;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int? to;
  final int total;

  PaginatedResponse({
    required this.currentPage,
    required this.data,
    this.firstPageUrl,
    this.from,
    required this.lastPage,
    this.lastPageUrl,
    required this.links,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    this.to,
    required this.total,
  });

  factory PaginatedResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJson) {
    final source = json['data'] ?? json['items'];
    List<dynamic> items = [];
    Map<String, dynamic> meta = {};

    if (source is Map<String, dynamic>) {
      if (source['data'] is List<dynamic>) {
        // Laravel default: { data: [...], current_page, last_page, total, ... }
        items = List<dynamic>.from(source['data']);
        meta = source;
      } else if (source.containsKey('items')) {
        items = List<dynamic>.from(source['items'] ?? []);
        meta = Map<String, dynamic>.from(source['meta'] ?? source);
      } else {
        items = [];
        meta = source;
      }
    } else if (source is List<dynamic>) {
      items = source;
      meta = json;
    }

    return PaginatedResponse(
      currentPage: meta['current_page'] ?? json['current_page'] ?? 1,
      data: items.map((item) => fromJson(item)).toList(),
      firstPageUrl: meta['first_page_url'],
      from: meta['from'],
      lastPage: meta['last_page'] ?? 1,
      lastPageUrl: meta['last_page_url'],
      links: (meta['links'] as List<dynamic>?)?.map((item) => Link.fromJson(item)).toList() ?? [],
      nextPageUrl: meta['next_page_url'],
      path: meta['path'] ?? '',
      perPage: meta['per_page'] ?? 10,
      prevPageUrl: meta['prev_page_url'],
      to: meta['to'],
      total: meta['total'] ?? 0,
    );
  }
}

class Link {
  final String? url;
  final String label;
  final bool active;

  Link({
    this.url,
    required this.label,
    required this.active,
  });

  factory Link.fromJson(Map<String, dynamic> json) {
    return Link(
      url: json['url'],
      label: json['label'],
      active: json['active'],
    );
  }
}