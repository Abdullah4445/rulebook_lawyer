import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lawyer/constant/collection_name.dart';
import 'package:lawyer/constant/constant.dart';
import 'package:lawyer/constant/show_toast_dialog.dart';
import 'package:lawyer/model/order_model.dart';
import 'package:lawyer/themes/app_colors.dart';
import 'package:lawyer/utils/DarkThemeProvider.dart';
import 'package:lawyer/utils/fire_store_utils.dart';
import 'package:lawyer/widget/consultation_propose_dialog.dart';
import 'package:lawyer/widget/wakalatnama_send_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

/// Per-case workspace shown to the lawyer inside a case detail screen:
///   • Private notes (lawyer-only, never shown to client)
///   • Shared document attachments
class LawyerCaseWorkspace extends StatefulWidget {
  final String orderId;
  const LawyerCaseWorkspace({Key? key, required this.orderId})
      : super(key: key);

  @override
  State<LawyerCaseWorkspace> createState() => _LawyerCaseWorkspaceState();
}

class _LawyerCaseWorkspaceState extends State<LawyerCaseWorkspace> {
  final TextEditingController _notesController = TextEditingController();
  bool _loading = true;
  bool _savingNotes = false;
  bool _uploading = false;
  List<CaseDocument> _documents = const [];
  String? _hydratedNotes;
  Wakalatnama? _wakalatnama;
  Consultation? _consultation;
  Dispute? _dispute;
  List<Hearing> _hearings = const [];

  DocumentReference<Map<String, dynamic>> get _orderDoc => FirebaseFirestore
      .instance
      .collection(CollectionName.orders)
      .doc(widget.orderId);

  @override
  void initState() {
    super.initState();
    _hydrate();
  }

  Future<void> _hydrate() async {
    try {
      final snap = await _orderDoc.get();
      if (!snap.exists) {
        setState(() => _loading = false);
        return;
      }
      final model = OrderModel.fromJson(snap.data()!);
      _hydratedNotes = model.lawyerPrivateNotes ?? '';
      _notesController.text = _hydratedNotes!;
      _documents = model.caseDocuments ?? const [];
      _wakalatnama = model.wakalatnama;
      _consultation = model.consultation;
      _dispute = model.dispute;
      _hearings = model.hearings ?? const [];
    } catch (_) {
      // Non-fatal — render with whatever we have.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveNotes() async {
    final newText = _notesController.text.trim();
    if (newText == (_hydratedNotes ?? '').trim()) {
      ShowToastDialog.showToast('No changes to save.'.tr);
      return;
    }
    setState(() => _savingNotes = true);
    try {
      await _orderDoc.set(
        {'lawyerPrivateNotes': newText.isEmpty ? null : newText},
        SetOptions(merge: true),
      );
      _hydratedNotes = newText;
      ShowToastDialog.showToast('Notes saved.'.tr);
    } catch (e) {
      ShowToastDialog.showToast('Could not save notes.'.tr);
    } finally {
      if (mounted) setState(() => _savingNotes = false);
    }
  }

  Future<void> _pickAndUploadDocument() async {
    setState(() => _uploading = true);
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: false,
      );
      if (picked == null || picked.files.isEmpty) return;
      final f = picked.files.first;
      if (f.path == null) return;
      final file = File(f.path!);
      final docId = const Uuid().v4();
      final safeName = f.name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
      final url = await Constant.uploadUserImageToFireStorage(
        file,
        'case_documents/${widget.orderId}',
        '${docId}_$safeName',
      );

      final newDoc = CaseDocument(
        id: docId,
        name: f.name,
        url: url,
        mimeType: _guessMime(f.name),
        uploadedBy: 'lawyer',
        uploadedAt: Timestamp.now(),
      );

      // Append to existing list on Firestore. Use FieldValue.arrayUnion for
      // simple append; rely on serialised CaseDocument map.
      await _orderDoc.set({
        'caseDocuments': FieldValue.arrayUnion([newDoc.toJson()]),
      }, SetOptions(merge: true));

      if (mounted) {
        setState(() {
          _documents = [..._documents, newDoc];
        });
      }
      ShowToastDialog.showToast('Document uploaded.'.tr);
    } catch (e) {
      ShowToastDialog.showToast('Could not upload document.'.tr);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _deleteDocument(CaseDocument doc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove document?'.tr),
        content: Text(
            'This will remove the document from the shared workspace.'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel'.tr),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Remove'.tr,
                style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _orderDoc.set({
        'caseDocuments': FieldValue.arrayRemove([doc.toJson()]),
      }, SetOptions(merge: true));
      if (mounted) {
        setState(() {
          _documents =
              _documents.where((d) => d.id != doc.id).toList(growable: false);
        });
      }
      ShowToastDialog.showToast('Document removed.'.tr);
    } catch (_) {
      ShowToastDialog.showToast('Could not remove document.'.tr);
    }
  }

  String _guessMime(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
      case 'docx':
        return 'application/msword';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'xls':
      case 'xlsx':
        return 'application/vnd.ms-excel';
      default:
        return 'application/octet-stream';
    }
  }

  IconData _iconFor(CaseDocument d) {
    final m = d.mimeType ?? '';
    if (m.startsWith('image/')) return Icons.image_outlined;
    if (m.contains('pdf')) return Icons.picture_as_pdf_outlined;
    if (m.contains('msword') || m.contains('officedocument')) {
      return Icons.description_outlined;
    }
    if (m.contains('excel') || m.contains('sheet')) {
      return Icons.table_chart_outlined;
    }
    return Icons.insert_drive_file_outlined;
  }

  Future<void> _openDocument(CaseDocument d) async {
    final url = d.url;
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) {
      ShowToastDialog.showToast('Invalid document link.'.tr);
      return;
    }
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) ShowToastDialog.showToast('Could not open document.'.tr);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Provider.of<DarkThemeProvider>(context).getThem();

    if (_loading) {
      return SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(
              color: AppColors.brandGold, strokeWidth: 2.5),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_dispute != null) ...[
          _disputeBanner(theme, isDark),
          const SizedBox(height: 14),
        ],
        _hearingsSection(theme, isDark),
        const SizedBox(height: 14),
        _consultationSection(theme, isDark),
        const SizedBox(height: 14),
        _wakalatnamaSection(theme, isDark),
        const SizedBox(height: 20),
        _sectionHeader(theme, isDark, Icons.edit_note_rounded,
            'Private Notes'.tr, 'Visible only to you'.tr),
        const SizedBox(height: 8),
        _notesEditor(theme, isDark),
        const SizedBox(height: 20),
        _sectionHeader(theme, isDark, Icons.folder_open_rounded,
            'Documents'.tr, 'Shared with the client'.tr),
        const SizedBox(height: 8),
        ..._documents
            .map((d) => _docTile(theme, isDark, d, canDelete: true))
            .toList(),
        if (_documents.isEmpty) _emptyDocs(theme, isDark),
        const SizedBox(height: 8),
        _uploadButton(theme, isDark),
      ],
    );
  }

  Widget _sectionHeader(
      ThemeData theme, bool isDark, IconData icon, String title, String hint) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: AppColors.goldGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 14),
        ),
        const SizedBox(width: 8),
        Text(title,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: theme.colorScheme.onSurface)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '· $hint',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _notesEditor(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkContainerBackground
            : AppColors.containerBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color:
                isDark ? AppColors.darkContainerBorder : AppColors.containerBorder,
            width: 0.8),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
            child: TextField(
              controller: _notesController,
              maxLines: 6,
              minLines: 4,
              style: GoogleFonts.poppins(
                  fontSize: 13.5, color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText:
                    'Strategy, key dates, opposing counsel, etc...'.tr,
                hintStyle: GoogleFonts.poppins(
                  fontSize: 12.5,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          Container(
            height: 1, color: theme.dividerColor.withValues(alpha: 0.3)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              children: [
                Icon(Icons.lock_outline_rounded,
                    size: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.45)),
                const SizedBox(width: 4),
                Text(
                  'Private to you'.tr,
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _savingNotes ? null : _saveNotes,
                  icon: _savingNotes
                      ? SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                              color: AppColors.brandGold, strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined, size: 14),
                  label: Text(_savingNotes ? 'Saving...'.tr : 'Save notes'.tr,
                      style: GoogleFonts.poppins(
                          fontSize: 11.5, fontWeight: FontWeight.w600)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.brandGoldDeep,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: const Size(0, 28),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _docTile(ThemeData theme, bool isDark, CaseDocument d,
      {required bool canDelete}) {
    final isMine = d.uploadedBy == 'lawyer';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkContainerBackground
            : AppColors.containerBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color:
                isDark ? AppColors.darkContainerBorder : AppColors.containerBorder,
            width: 0.8),
      ),
      child: ListTile(
        dense: true,
        onTap: () => _openDocument(d),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.brandGold.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_iconFor(d),
              color: AppColors.brandGoldDeep, size: 18),
        ),
        title: Text(
          d.name ?? 'Document',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: theme.colorScheme.onSurface),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          isMine ? 'Uploaded by you'.tr : 'From the client'.tr,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
        trailing: canDelete && isMine
            ? IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Colors.redAccent, size: 18),
                onPressed: () => _deleteDocument(d),
              )
            : const Icon(Icons.open_in_new_rounded, size: 16),
      ),
    );
  }

  Widget _emptyDocs(ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(Icons.folder_open_rounded,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              size: 28),
          const SizedBox(height: 6),
          Text(
            'No documents shared yet'.tr,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────── HEARINGS (Phase 2.1) ───────────────────────
  Hearing? get _nextHearing {
    final now = DateTime.now();
    final upcoming = _hearings
        .where((h) =>
            h.status != 'completed' &&
            h.dateTime != null &&
            h.dateTime!.toDate().isAfter(now))
        .toList()
      ..sort((a, b) => a.dateTime!.toDate().compareTo(b.dateTime!.toDate()));
    return upcoming.isEmpty ? null : upcoming.first;
  }

  Widget _hearingsSection(ThemeData theme, bool isDark) {
    final next = _nextHearing;
    final fmt = DateFormat('EEE, MMM d · h:mm a');
    final sorted = [..._hearings]..sort((a, b) {
        final da = a.dateTime?.toDate();
        final db = b.dateTime?.toDate();
        if (da == null || db == null) return 0;
        return db.compareTo(da); // newest first
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _sectionHeader(theme, isDark, Icons.event_note_rounded,
                  'Hearings'.tr, 'Court date schedule'.tr),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.brandGold,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: const Size(0, 32),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9)),
              ),
              onPressed: () => _addOrEditHearing(),
              icon: const Icon(Icons.add_rounded, size: 14),
              label: Text('Add'.tr,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (next != null) _nextHearingBanner(theme, next, fmt),
        if (next != null) const SizedBox(height: 8),
        if (sorted.isEmpty)
          _emptyHearings(theme)
        else
          ...sorted.map((h) => _hearingTile(theme, isDark, h, fmt)),
      ],
    );
  }

  Widget _nextHearingBanner(ThemeData theme, Hearing h, DateFormat fmt) {
    final dt = h.dateTime!.toDate();
    final days = dt.difference(DateTime.now()).inDays;
    final countdown = days <= 0
        ? 'Today'.tr
        : days == 1
            ? 'Tomorrow'.tr
            : 'in $days ${"days".tr}';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active_rounded,
              color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Next hearing · $countdown',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5)),
                const SizedBox(height: 2),
                Text('${fmt.format(dt)}${(h.courtName ?? '').isNotEmpty ? " · ${h.courtName}" : ""}',
                    style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.95),
                        fontSize: 11.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyHearings(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(Icons.event_busy_rounded,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              size: 26),
          const SizedBox(height: 6),
          Text('No hearings scheduled'.tr,
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  color:
                      theme.colorScheme.onSurface.withValues(alpha: 0.55))),
        ],
      ),
    );
  }

  Widget _hearingTile(
      ThemeData theme, bool isDark, Hearing h, DateFormat fmt) {
    final dt = h.dateTime?.toDate();
    final status = h.status ?? 'scheduled';
    Color sc;
    switch (status) {
      case 'completed':
        sc = const Color(0xFF1D7A3A);
        break;
      case 'adjourned':
        sc = const Color(0xFFB07F00);
        break;
      default:
        sc = AppColors.brandGoldDeep;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkContainerBackground
            : AppColors.containerBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: isDark
                ? AppColors.darkContainerBorder
                : AppColors.containerBorder,
            width: 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: sc.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.gavel_rounded, color: sc, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dt != null ? fmt.format(dt) : '—',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                        color: theme.colorScheme.onSurface)),
                if ((h.purpose ?? '').isNotEmpty || (h.courtName ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text(
                      [h.courtName, h.purpose]
                          .where((e) => (e ?? '').isNotEmpty)
                          .join(' · '),
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6)),
                    ),
                  ),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: sc.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    status[0].toUpperCase() + status.substring(1),
                    style: GoogleFonts.poppins(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: sc),
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded,
                size: 18,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
            onSelected: (v) {
              if (v == 'edit') _addOrEditHearing(existing: h);
              if (v == 'done') _setHearingStatus(h, 'completed');
              if (v == 'adjourn') _setHearingStatus(h, 'adjourned');
              if (v == 'delete') _deleteHearing(h);
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'edit', child: Text('Edit'.tr)),
              if (status != 'completed')
                PopupMenuItem(value: 'done', child: Text('Mark completed'.tr)),
              if (status != 'adjourned')
                PopupMenuItem(value: 'adjourn', child: Text('Mark adjourned'.tr)),
              PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'.tr,
                      style: const TextStyle(color: Colors.redAccent))),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _persistHearings() async {
    await _orderDoc.set(
      {'hearings': _hearings.map((h) => h.toJson()).toList()},
      SetOptions(merge: true),
    );
  }

  Future<void> _setHearingStatus(Hearing h, String status) async {
    final idx = _hearings.indexWhere((x) => x.id == h.id);
    if (idx < 0) return;
    _hearings[idx].status = status;
    try {
      await _persistHearings();
      ShowToastDialog.showToast('Hearing updated.'.tr);
      await _hydrate();
    } catch (_) {
      ShowToastDialog.showToast('Could not update.'.tr);
    }
  }

  Future<void> _deleteHearing(Hearing h) async {
    _hearings = _hearings.where((x) => x.id != h.id).toList();
    try {
      await _persistHearings();
      ShowToastDialog.showToast('Hearing removed.'.tr);
      await _hydrate();
    } catch (_) {
      ShowToastDialog.showToast('Could not remove.'.tr);
    }
  }

  Future<void> _addOrEditHearing({Hearing? existing}) async {
    final courtCtrl =
        TextEditingController(text: existing?.courtName ?? '');
    final purposeCtrl =
        TextEditingController(text: existing?.purpose ?? '');
    final noteCtrl = TextEditingController(text: existing?.note ?? '');
    DateTime selected =
        existing?.dateTime?.toDate() ?? DateTime.now().add(const Duration(days: 1));

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fmt = DateFormat('EEE, MMM d · h:mm a');

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setLocal) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            title: Text(existing == null ? 'Add hearing'.tr : 'Edit hearing'.tr,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700, fontSize: 15)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () async {
                      final d = await showDatePicker(
                        context: ctx,
                        initialDate: selected,
                        firstDate: DateTime.now()
                            .subtract(const Duration(days: 365)),
                        lastDate:
                            DateTime.now().add(const Duration(days: 730)),
                      );
                      if (d == null) return;
                      final t = await showTimePicker(
                        context: ctx,
                        initialTime: TimeOfDay.fromDateTime(selected),
                      );
                      if (t == null) return;
                      setLocal(() {
                        selected = DateTime(
                            d.year, d.month, d.day, t.hour, t.minute);
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: AppColors.brandGold.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.brandGold
                                .withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              size: 16, color: AppColors.brandGoldDeep),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(fmt.format(selected),
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12.5)),
                          ),
                          Icon(Icons.edit_rounded,
                              size: 14,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5)),
                        ],
                      ),
                    ),
                  ),
                  _hearingField(ctx, isDark, courtCtrl,
                      'Court (e.g. District Court, Vehari)'.tr),
                  const SizedBox(height: 8),
                  _hearingField(ctx, isDark, purposeCtrl,
                      'Purpose (e.g. Arguments, Evidence)'.tr),
                  const SizedBox(height: 8),
                  _hearingField(ctx, isDark, noteCtrl, 'Note (optional)'.tr,
                      maxLines: 2),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text('Cancel'.tr)),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brandGold),
                child: Text('Save'.tr),
              ),
            ],
          );
        });
      },
    );

    if (saved != true) return;
    ShowToastDialog.showLoader('Saving...'.tr);
    if (existing != null) {
      final idx = _hearings.indexWhere((x) => x.id == existing.id);
      if (idx >= 0) {
        _hearings[idx]
          ..dateTime = Timestamp.fromDate(selected)
          ..courtName = courtCtrl.text.trim()
          ..purpose = purposeCtrl.text.trim()
          ..note = noteCtrl.text.trim();
      }
    } else {
      _hearings = [
        ..._hearings,
        Hearing(
          id: const Uuid().v4(),
          dateTime: Timestamp.fromDate(selected),
          courtName: courtCtrl.text.trim(),
          purpose: purposeCtrl.text.trim(),
          note: noteCtrl.text.trim(),
          status: 'scheduled',
        ),
      ];
    }
    try {
      await _persistHearings();
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('Hearing saved.'.tr);
      await _hydrate();
    } catch (_) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('Could not save hearing.'.tr);
    }
  }

  Widget _hearingField(BuildContext ctx, bool isDark,
      TextEditingController controller, String hint,
      {int maxLines = 1}) {
    final theme = Theme.of(ctx);
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style:
          GoogleFonts.poppins(fontSize: 13, color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
                color: theme.dividerColor.withValues(alpha: 0.4))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: AppColors.brandGold, width: 1.3)),
      ),
    );
  }

  Widget _disputeBanner(ThemeData theme, bool isDark) {
    final d = _dispute!;
    final status = d.status ?? 'submitted';
    final hasResponded = (d.lawyerResponse ?? '').isNotEmpty;
    Color color;
    IconData icon;
    String title;
    switch (status) {
      case 'approved':
        color = const Color(0xFF1D7A3A);
        icon = Icons.check_circle_outline_rounded;
        title = 'Dispute approved by admin'.tr;
        break;
      case 'rejected':
        color = Colors.redAccent;
        icon = Icons.cancel_outlined;
        title = 'Dispute rejected by admin'.tr;
        break;
      case 'under_review':
        color = const Color(0xFFB07F00);
        icon = Icons.search_rounded;
        title = 'Dispute under review'.tr;
        break;
      default:
        color = Colors.redAccent;
        icon = Icons.flag_rounded;
        title = 'Client opened a dispute'.tr;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: color.withValues(alpha: 0.45), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: color)),
                    if (d.amount != null)
                      Text(
                        'Refund requested: ${d.amount!.toStringAsFixed(0)}'.tr,
                        style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            color: color.withValues(alpha: 0.85)),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if ((d.reason ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Client says: ${d.reason}'.tr,
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  height: 1.4,
                  color:
                      theme.colorScheme.onSurface.withValues(alpha: 0.80),
                ),
              ),
            ),
          ],
          if (!hasResponded && status != 'approved' && status != 'rejected')
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showLawyerResponseDialog(d),
                  icon: const Icon(Icons.reply_rounded, size: 14),
                  label: Text('Respond to dispute'.tr,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: color,
                    side: BorderSide(color: color.withValues(alpha: 0.6)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ),
          if (hasResponded) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              width: double.infinity,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Your response: ${d.lawyerResponse}'.tr,
                style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.85)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showLawyerResponseDialog(Dispute d) async {
    final ctrl = TextEditingController();
    final theme = Theme.of(context);
    final response = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          title: Text('Respond to dispute'.tr,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700, fontSize: 15)),
          content: SingleChildScrollView(
            child: TextField(
              controller: ctrl,
              maxLines: 5,
              decoration: InputDecoration(
                hintText:
                    'Explain your side of the story to the admin...'.tr,
                hintStyle: GoogleFonts.poppins(fontSize: 12.5),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Cancel'.tr)),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brandGold),
              child: Text('Send'.tr),
            ),
          ],
        );
      },
    );
    if (response == null || response.isEmpty) return;

    ShowToastDialog.showLoader('Sending...'.tr);
    try {
      final updated = Dispute(
        status: d.status,
        reason: d.reason,
        amount: d.amount,
        customerEvidenceUrls: d.customerEvidenceUrls,
        lawyerResponse: response,
        lawyerResponseAt: Timestamp.now(),
        adminNote: d.adminNote,
        createdAt: d.createdAt,
        resolvedAt: d.resolvedAt,
      );
      await _orderDoc.set({'dispute': updated.toJson()},
          SetOptions(merge: true));
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('Response sent.'.tr);
      await _hydrate();
    } catch (_) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('Could not send response.'.tr);
    }
  }

  Widget _consultationSection(ThemeData theme, bool isDark) {
    final c = _consultation;
    final status = c?.status ?? 'not_set';
    final fmt = DateFormat('EEE, MMM d · h:mm a');

    Color color;
    IconData icon;
    String title;
    String subtitle;
    switch (status) {
      case 'confirmed':
        color = const Color(0xFF1D7A3A);
        icon = Icons.event_available_rounded;
        title = 'Consultation confirmed'.tr;
        final s = c?.confirmedSlot?.start?.toDate();
        subtitle = s != null
            ? '${fmt.format(s)} · ${c?.confirmedSlot?.durationMinutes ?? 30} min'
            : 'Client picked a slot.'.tr;
        break;
      case 'proposed':
        color = const Color(0xFFB07F00);
        icon = Icons.hourglass_top_rounded;
        title = 'Awaiting client to pick'.tr;
        subtitle =
            'You proposed ${c?.proposedSlots?.length ?? 0} ${"slot(s)".tr}.';
        break;
      default:
        color = AppColors.brandGoldDeep;
        icon = Icons.calendar_today_rounded;
        title = 'Consultation'.tr;
        subtitle = 'Propose 1-3 time slots for the client.'.tr;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkContainerBackground
            : AppColors.containerBackground,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: color.withValues(alpha: 0.40), width: 1.1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: theme.colorScheme.onSurface,
                    )),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.60),
                    )),
              ],
            ),
          ),
          if (status == 'not_set' || status == 'proposed')
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.brandGold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                minimumSize: const Size(0, 34),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final ok = await showProposeConsultationDialog(
                    context, widget.orderId);
                if (ok) await _hydrate();
              },
              icon: const Icon(Icons.add_rounded, size: 14),
              label: Text(
                status == 'proposed' ? 'Update'.tr : 'Propose'.tr,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _wakalatnamaSection(ThemeData theme, bool isDark) {
    final w = _wakalatnama;
    final status = w?.status ?? 'not_sent';

    Color color;
    IconData icon;
    String title;
    String subtitle;
    switch (status) {
      case 'signed':
        color = const Color(0xFF1D7A3A);
        icon = Icons.verified_rounded;
        title = 'Wakalatnama signed'.tr;
        final signedAt = w?.signedAt?.toDate();
        subtitle = signedAt != null
            ? 'Client signed on ${signedAt.day}/${signedAt.month}/${signedAt.year}'
                .tr
            : 'Client has signed the wakalatnama'.tr;
        break;
      case 'sent':
        color = const Color(0xFFB07F00);
        icon = Icons.hourglass_top_rounded;
        title = 'Awaiting client signature'.tr;
        subtitle = 'Sent — client will review and sign.'.tr;
        break;
      default:
        color = AppColors.brandGoldDeep;
        icon = Icons.gavel_rounded;
        title = 'Wakalatnama'.tr;
        subtitle = 'Send the Power of Attorney to your client.'.tr;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkContainerBackground
            : AppColors.containerBackground,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: color.withValues(alpha: 0.40), width: 1.1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.60),
                  ),
                ),
              ],
            ),
          ),
          if (status == 'not_sent')
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.brandGold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                minimumSize: const Size(0, 34),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final ok = await showSendWakalatnamaDialog(
                    context, widget.orderId);
                if (ok) await _hydrate();
              },
              icon: const Icon(Icons.send_rounded, size: 14),
              label: Text(
                'Send'.tr,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ),
          if (status == 'signed' && (w?.signatureUrl ?? '').isNotEmpty)
            IconButton(
              icon: Icon(Icons.image_outlined,
                  color: AppColors.brandGoldDeep, size: 20),
              tooltip: 'View signature'.tr,
              onPressed: () => _openDocument(CaseDocument(
                name: 'Client signature',
                url: w!.signatureUrl,
                mimeType: 'image/png',
              )),
            ),
        ],
      ),
    );
  }

  Widget _uploadButton(ThemeData theme, bool isDark) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: _uploading ? null : _pickAndUploadDocument,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          gradient: AppColors.goldGradient,
          borderRadius: BorderRadius.circular(10),
          boxShadow: _uploading
              ? null
              : [
                  BoxShadow(
                    color: AppColors.brandGold.withValues(alpha: 0.30),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _uploading
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.upload_file_rounded,
                    color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              _uploading ? 'Uploading...'.tr : 'Upload document'.tr,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
