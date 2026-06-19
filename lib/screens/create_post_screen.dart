import 'package:flutter/material.dart';
import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _postType = 'General';
  bool _allowComments = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Your post has been created on the news feed.')),
    );

    Navigator.of(context).pop();
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Create Post',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Share news, questions, event alerts, or useful resources with your campus feed.',
          style: TextStyle(color: Colors.grey[700], height: 1.5),
        ),
      ],
    );
  }

  Widget _buildTypeChips() {
    final types = ['General', 'Announcement', 'Question', 'Resource'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: types.map((type) {
        final selected = _postType == type;
        return ChoiceChip(
          label: Text(type),
          selected: selected,
          selectedColor: Theme.of(context).primaryColor,
          backgroundColor: Colors.grey[200],
          labelStyle: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
          onSelected: (_) => setState(() => _postType = type),
        );
      }).toList(),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Headline',
              hintText: 'Enter a short, clear title for your post',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              filled: true,
              fillColor: Colors.white,
            ),
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a headline for your post.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _contentController,
            decoration: InputDecoration(
              labelText: 'Post Details',
              hintText: 'Write the content of your post here...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              filled: true,
              fillColor: Colors.white,
            ),
            keyboardType: TextInputType.multiline,
            maxLines: 8,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please add details before posting.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTypeChips(),
          const SizedBox(height: 16),
          Row(
            children: [
              Switch(
                value: _allowComments,
                onChanged: (value) => setState(() => _allowComments = value),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Allow comments on this post',
                  style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF2962FF),
                child: Icon(Icons.photo, color: Colors.white),
              ),
              title: const Text('Add media or file'),
              subtitle: const Text('Attach an image, document or resource link'),
              trailing: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Media upload is not available in demo mode.')),
                  );
                },
                child: const Text('Browse'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton.icon(
      onPressed: _isSubmitting ? null : _submitPost,
      icon: const Icon(Icons.send),
      label: Text(_isSubmitting ? 'Posting...' : 'Publish to News Feed'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return VibeScaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildForm(),
            const SizedBox(height: 24),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }
}
