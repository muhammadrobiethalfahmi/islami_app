import 'package:flutter/material.dart';
import '../core/theme_notifier.dart'; 
import '../services/notification_service.dart'; // Import service notifikasi kita
import 'profile_page.dart'; // 👈 Tambahkan import halaman profile ke sini

class PengaturanPage extends StatefulWidget {
  const PengaturanPage({super.key});

  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
  bool _isAdzanReminder = true;
  bool _isSilentMode = false;
  
  // Variabel untuk menyimpan audio adzan yang terpilih (default: adzan_makka)
  String _selectedAdzan = 'adzan_makka'; 

  // FUNGSI UNTUK MENAMPILKAN PILIHAN ADZAN (BOTTOM SHEET)
  void _showAdzanSelectionModal(BuildContext context) {
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, bottom: 16.0),
                    child: Text(
                      'Pilih Nada Dering Adzan',
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold, 
                        color: theme.colorScheme.primary
                      ),
                    ),
                  ),
                  
                  // Pilihan 1: Mekkah
                  RadioListTile<String>(
                    title: const Text('Mekkah', style: TextStyle(fontWeight: FontWeight.w600)),
                    value: 'adzan_makka', // Menyesuaikan nama file di folder res/raw
                    groupValue: _selectedAdzan,
                    activeColor: theme.colorScheme.primary,
                    onChanged: (value) {
                      setState(() => _selectedAdzan = value!);
                      Navigator.pop(context); // Tutup dialog setelah memilih
                    },
                  ),
                  
                  // Pilihan 2: Madinah
                  RadioListTile<String>(
                    title: const Text('Madinah', style: TextStyle(fontWeight: FontWeight.w600)),
                    value: 'adzan_madinah', // Menyesuaikan nama file di folder res/raw
                    groupValue: _selectedAdzan,
                    activeColor: theme.colorScheme.primary,
                    onChanged: (value) {
                      setState(() => _selectedAdzan = value!);
                      Navigator.pop(context); // Tutup dialog setelah memilih
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, 
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: colorScheme.onSurface, size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Pengaturan',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary, 
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔴 DI SINI MENU BARU PROFIL YANG DITAMBAHKAN 🔴
                    _buildSectionTitle('AKUN', colorScheme),
                    _buildGroupCard(
                      context,
                      [
                        _buildSettingTile(
                          context: context,
                          icon: Icons.person_outline_rounded,
                          title: 'Profil Pengguna',
                          subtitle: 'Lihat nama, email, dan keluar akun',
                          showChevron: true,
                          onTap: () {
                            // Navigasi masuk ke halaman ProfilePage
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ProfilePage()),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // KODE ASLI ABANG KE BAWAH TIDAK ADA YANG DIUBAH 👍
                    _buildSectionTitle('TAMPILAN', colorScheme),
                    _buildGroupCard(
                      context,
                      [
                        _buildSettingTile(
                          context: context,
                          icon: Icons.dark_mode_outlined,
                          title: 'Mode Gelap',
                          trailingWidget: ValueListenableBuilder<ThemeMode>(
                            valueListenable: themeNotifier,
                            builder: (context, currentMode, _) {
                              return _buildSwitch(
                                value: currentMode == ThemeMode.dark,
                                onChanged: (val) {
                                  themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                                },
                              );
                            },
                          ),
                        ),
                        _buildDivider(context),
                        _buildSettingTile(
                          context: context,
                          icon: Icons.text_fields_rounded,
                          title: 'Ukuran Teks',
                          trailingText: 'Sedang',
                          showChevron: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('NOTIFIKASI', colorScheme),
                    _buildGroupCard(
                      context,
                      [
                        _buildSettingTile(
                          context: context,
                          icon: _isSilentMode 
                              ? Icons.notifications_off_outlined 
                              : (_isAdzanReminder ? Icons.notifications_active_outlined : Icons.notifications_outlined),
                          title: 'Pengingat Adzan',
                          subtitle: _isSilentMode 
                              ? 'Tidak berfungsi karena Mode Hening aktif' 
                              : (_isAdzanReminder ? 'Suara & Getar' : 'Hanya Notifikasi (Senyap)'),
                          isDisabled: _isSilentMode, 
                          trailingWidget: _buildSwitch(
                            value: _isSilentMode ? false : _isAdzanReminder,
                            onChanged: _isSilentMode 
                                ? null 
                                : (val) => setState(() => _isAdzanReminder = val),
                          ),
                        ),
                        _buildDivider(context),
                        
                        // MENDAFTARKAN FUNGSI KLIK PADA NADA DERING ADZAN
                        _buildSettingTile(
                          context: context,
                          icon: Icons.volume_up_outlined,
                          title: 'Nada Dering Adzan',
                          trailingText: _selectedAdzan == 'adzan_makka' ? 'Mekkah' : 'Madinah',
                          showChevron: !_isSilentMode,
                          isDisabled: _isSilentMode,
                          onTap: _isSilentMode ? null : () => _showAdzanSelectionModal(context),
                        ),
                        _buildDivider(context),
                        _buildSettingTile(
                          context: context,
                          icon: Icons.do_not_disturb_on_outlined,
                          title: 'Mode Hening',
                          subtitle: 'Selama waktu sholat',
                          trailingWidget: _buildSwitch(
                            value: _isSilentMode,
                            onChanged: (val) {
                              setState(() {
                                _isSilentMode = val;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // TOMBOL TEST TRIGER UNTUK MENDENGARKAN HASIL PILIHAN
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Test Suara Adzan Terpilih'),
                        onPressed: () {
                          NotificationService.tampilkanAdzan(
                            namaFileAdzan: _selectedAdzan, 
                            isSilentMode: _isSilentMode,
                            isAdzanReminder: _isAdzanReminder,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 10.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: colorScheme.onSurface.withOpacity(0.6), letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildGroupCard(BuildContext context, List<Widget> tiles) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(children: tiles),
    );
  }

  // MENAMBAHKAN PARAMETER OPTIONAL 'onTap' DI HELPER WIDGET TILE
  Widget _buildSettingTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    String? trailingText,
    Widget? trailingWidget,
    bool showChevron = false,
    bool isDisabled = false, 
    VoidCallback? onTap, 
  }) {
    final theme = Theme.of(context);
    final double opacity = isDisabled ? 0.35 : 1.0;

    return Opacity(
      opacity: opacity,
      child: InkWell(
        onTap: isDisabled ? null : onTap, 
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5), shape: BoxShape.circle),
                child: Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                    if (subtitle != null) ...[const SizedBox(height: 2), Text(subtitle, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6)))],
                  ],
                ),
              ),
              if (trailingText != null) Text(trailingText, style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.6))),
              if (showChevron) ...[const SizedBox(width: 6), Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurface.withOpacity(0.4), size: 20)],
              if (trailingWidget != null) trailingWidget,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(height: 1, thickness: 1, indent: 16, endIndent: 16, color: Theme.of(context).dividerColor);
  }

  Widget _buildSwitch({required bool value, required ValueChanged<bool>? onChanged}) {
    return SizedBox(
      height: 28,
      width: 48,
      child: Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: Theme.of(context).colorScheme.primary, 
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}