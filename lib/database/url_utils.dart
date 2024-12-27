String fixImageUrl(String? url) {
  if (url == null || url.isEmpty) {
    return '';
  }
  if (url.startsWith('https:/') && !url.startsWith('https://')) {
    url = url.replaceFirst('https:/', 'https://');
  }
  url = url.replaceAll(' ', '%20');
  return url;
}
