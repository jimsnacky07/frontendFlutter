// lib/models.dart

class Kamar {
  final String id;
  final int lantai;
  final String kapasitas;
  final String fasilitas;
  final int tarif;
  final int maxPenghuni;

  Kamar({
    required this.id,
    required this.lantai,
    required this.kapasitas,
    required this.fasilitas,
    required this.tarif,
    required this.maxPenghuni,
  });

  factory Kamar.fromJson(Map<String, dynamic> json) {
    return Kamar(
      id: json['id']?.toString() ?? '',
      lantai: json['lantai'] ?? 0,
      kapasitas: json['kapasitas'] ?? '',
      fasilitas: json['fasilitas'] ?? '',
      tarif: json['tarif'] ?? 0,
      maxPenghuni: json['max_penghuni'] ?? 0,
    );
  }
}

class Keuangan {
  final int id;
  final String tglBayar;
  final int bayar;
  final String keterangan;
  final String? foto; // Tambahkan kembali field foto

  Keuangan({
    required this.id,
    required this.tglBayar,
    required this.bayar,
    required this.keterangan,
    this.foto, // Optional field
  });

  factory Keuangan.fromJson(Map<String, dynamic> json) {
    return Keuangan(
      id: json['id'] ?? 0,
      tglBayar: json['tgl_bayar'] ?? '',
      bayar: json['bayar'] ?? 0,
      keterangan: json['keterangan'] ?? '',
      foto: json['foto'], // Ambil field foto
    );
  }
}

class Tagihan {
  final int id;
  final String bulan;
  final int tahun;
  final int tagihan;
  final String status;
  final String? foto; // Tambahkan field foto

  Tagihan({
    required this.id,
    required this.bulan,
    required this.tahun,
    required this.tagihan,
    required this.status,
    this.foto, // Optional field
  });

  factory Tagihan.fromJson(Map<String, dynamic> json) {
    return Tagihan(
      id: int.tryParse(json['id'].toString()) ?? 0,
      bulan: json['bulan'] ?? '',
      tahun: int.tryParse(json['tahun'].toString()) ?? 0,
      tagihan: (() {
        final tagihanStr = json['tagihan'].toString();
        if (tagihanStr.contains('.')) {
          return int.tryParse(tagihanStr.split('.').first) ?? 0;
        }
        return int.tryParse(tagihanStr) ?? 0;
      })(),
      status: json['status'] ?? '',
      foto: json['foto'], // Ambil field foto
    );
  }
}

class Penghuni {
  final String id;
  final String nama;
  final String alamat;
  final String nohp;
  final String registrasi;
  final String tanggalBayar;
  final Kamar? kamar;
  final List<Keuangan> keuangan;
  final List<Tagihan> tagihan;

  Penghuni({
    required this.id,
    required this.nama,
    required this.alamat,
    required this.nohp,
    required this.registrasi,
    required this.tanggalBayar,
    this.kamar,
    required this.keuangan,
    required this.tagihan,
  });

  factory Penghuni.fromJson(Map<String, dynamic> json) {
    return Penghuni(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      alamat: json['alamat'] ?? '',
      nohp: json['nohp'] ?? '',
      registrasi: json['registrasi'] ?? '',
      tanggalBayar: json['tanggal_bayar'] ?? '',
      kamar: json['kamar'] != null ? Kamar.fromJson(json['kamar']) : null,
      keuangan: (json['keuangan'] as List<dynamic>? ?? [])
          .map((e) => Keuangan.fromJson(e))
          .toList(),
      tagihan: (json['tagihan'] as List<dynamic>? ?? [])
          .map((e) => Tagihan.fromJson(e))
          .toList(),
    );
  }
} 