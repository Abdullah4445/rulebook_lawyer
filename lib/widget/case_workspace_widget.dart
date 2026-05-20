import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lawyer/constant/collection_name.dart';
import 'package:lawyer/constant/constant.dart';
import 'package:lawyer/constant/show_toast_dialog.dart';
import 'package:lawyer/model/order_model.dart';
import 'package:lawyer/themes/app_colors.dart';
import 'package:lawyer/utils/DarkThemeProvider.dart';
import 'package:lawyer/utils/fire_store_utils.dart';
import 'package:file_picker/file_picker.dart';
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
